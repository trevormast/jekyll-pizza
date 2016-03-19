require 'sinatra'
require 'sinatra/auth/github'
require './lib/view_helpers'
require './lib/dweet_pizza'
require './jobs/commit_job'
require './lib/order'
require './lib/delivery'
require './lib/recipe'
require './lib/oven'
require './lib/taste_test'
require 'rack/ssl-enforcer'
require 'dweet'
require 'pry' if AppEnv.development?
# require 'httplog' if AppEnv.development?

module JekyllPizza
  class App < Sinatra::Base
    use Rack::SslEnforcer if AppEnv.production?
    set :session_secret, ENV['RACK_SESSION_SECRET']
    use Rack::Session::Cookie, key: '_jekyllpizza_session',
                               path: '/',
                               expire_after: 2_592_000, # In seconds
                               secret: settings.session_secret
    include ViewHelpers
    set :github_options,       scopes: 'public_repo',
                               secret: ENV['GITHUB_CLIENT_SECRET'],
                               client_id: ENV['GITHUB_CLIENT_ID']

    include BlogPoole::DweetPizza

    register Sinatra::Auth::Github

    get '/' do
      @flash ||= []
      slim :index, layout: :default 
    end

    get '/new' do
      # TODO: improve flash messaging
      @flash ||= []
      @flash << params[:error] if params[:error]
      setup_user
      dweet_login

      slim :new, layout: :default
    end

    post '/create' do
      @flash ||= []
      setup_user
      @failures ||= 0

      begin
        # TODO: improve validations
        order = Order.new(user: @user, 
                          params: params)

        if @api.repository?(order.user_repo_path)
          @failures += 1
          redirect "/new?error=Oops, that repository already exists, pick a new path!&failures=#{@failures}"
        end

        # site_info = Delivery.new(order: order, 
        #                          directory: Recipe.new(order.site_params).dir,
        #                          repo: Oven.new, 
        #                          build_status: TasteTest.new).run

        create_blog(order)

        @repo = @site_info[:repo]
        @site_url = @site_info[:full_repo_url]
        # dweet_creation
        slim :create, layout: :default
      rescue PathError => p
        @failures += 1
        redirect "/new?error=#{p.message}"  
      rescue StandardError => e
        # TODO: improve logging, error handling.. issue #
        puts e.message
        @failures += 1
        redirect "/new?error=Some shit happened!&failures=#{@failures}"
      end
    end

    get '/create' do
      redirect '/new'
    end

    get '/failure' do
      @flash ||= []
      @flash << session.delete(:error) if session[:error]
      slim :failure, layout: :default
    end

    get '/thanks' do
      @flash ||= []
      slim :thanks, layout: :default
    end

    get '/attribution' do
      @flash ||= []
      slim :attribution, layout: :default
    end

    get '/donate' do
      @flash ||= []
      slim :donate, layout: :default
    end

    # helper methods

    def setup_user
      authenticate!
      @flash << session.dete(:error) if session[:error]
      @user ||= github_user
      @api ||= @user.api
      @existing_root_repo ||= check_root_repo_status
    end

    def check_root_repo_status
      @api.repository?("#{@user.login}/#{@user.login}.github.io")
    end

    def create_blog(order)
      @site_info = CommitJob.perform_async(order)
    end
  end
end

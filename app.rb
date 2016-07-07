require 'sinatra'
require 'sinatra/auth/github'
require 'sidekiq_status'
require 'json'
require './workers/commit_worker'
require 'rack/ssl-enforcer'
require 'dweet'
require 'pry' if AppEnv.development?
Dir['./lib/**/*.rb'].each { |file| require file }

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
        create_blog(@user.token, params)

        @repo = repo_name(order)
        @site_url = blog_url(order)
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

    get '/worker_status.json' do
      # '/worker_status.json?job_id="asdfs4dfs56df7sdf"'
      @job_id = params['job_id']

      @container = SidekiqStatus::Container.load(@job_id)
      @container.reload

      content_type :json
      { worker_status: "#{@container.status}", at: "#{@container.at}", message: "#{@container.message}" }.to_json
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

    def repo_name(order)
      return "https://github.com/#{order.user.login}/#{order.user.login}.github.io" if order.root_repo
      "https://github.com/#{order.user.login}#{order.site_params['baseurl']}"
    end

    def blog_url(order)
      return "https://#{order.user.login}.github.io" if order.root_repo
      "https://#{order.user.login}.github.io#{order.site_params['baseurl']}"
    end

    def create_blog(token, params)
      @job_id = CommitWorker.perform_async(token, params)
    end
  end
end

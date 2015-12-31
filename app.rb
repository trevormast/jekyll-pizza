require 'sinatra'
require 'sinatra/auth/github'
require './lib/view_helpers'
require './lib/dweet'
require './oven'
require 'rack/ssl-enforcer'
require 'dweet'
require 'pry' if AppEnv.development?

module BlogPoole
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
    include DweetPizza

    register Sinatra::Auth::Github

    get '/' do
      @flash ||= []
      slim :index, layout: :default
    end

    get '/new' do
      # TODO: improve flash messaging
      @flash ||= []
      @flash << params[:error] if params[:error]
      authenticate!
      setup_user
      dweet_login

      slim :new, layout: :default
    end

    post '/create' do
      @flash ||= []
      authenticate!
      setup_user
      @oven = Oven.new(@api, @user, site_params, params)
      @failures ||= 0

      begin
        # TODO: improve validations
        if @api.repository?(@oven.user_repo_path(site_params))
          @failures += 1
          redirect "/new?error=Oops, that repository already exists, pick a new path!&failures=#{@failures}"
        end
        new_site = @oven.bake
        @repo = new_site[:repo]
        @site_url = new_site[:site_url]
        dweet_creation
        slim :create, layout: :default
      rescue StandardError => e
        # TODO: improve logging, error handling.. issue #
        puts e.message
        @failures += 1
        redirect "/new?error=Some shit happened!&failures=#{@failures}"
      end
    end

    # get '/test' do
    #   @flash ||= []
    #   authenticate!
    #   setup_user
      
    #   self.params = {"site"=>
    #     {"title"=>"", "description"=>"", "root_url"=>"amoose.github.io", "path"=>""}}

    #   # todo improve validations
    #   if @api.repository?(user_repo_path(site_params))
    #     redirect "/new?error=Sorry, that repository already exists, pick a new path!"
    #   end

    #   @repo = create_jekyll_repo(site_params)
    #   @site_url = full_repo_url(site_params)
    #   slim :create, layout: :default
    # end

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

    get '/donate' do
      @flash ||= []
      slim :donate, layout: :default
    end

    # helper methods
    def check_root_repo_status
      @api.repository?("#{@user.login}/#{@user.login}.github.io")
    end

    def site_params
      safe_params = {}
      safe_params['title'] = params['site']['title'] unless params['site']['title'].blank?
      safe_params['description'] = params['site']['description'] unless params['site']['description'].blank?

      # TODO: improve this logic
      safe_params['baseurl'] = params['site']['path']
      safe_params['baseurl'] = '/' + safe_params['baseurl'] unless safe_params['baseurl'].match(/^\//) || params['site']['path'].blank?

      safe_params['url'] = "#{@user.login}.github.io"
      safe_params['github_username'] = @user.login
      safe_params['theme'] = params['site']['theme']
      # safe_params['email'] = @user.email

      safe_params
    end

    def setup_user
      @flash << session.dete(:error) if session[:error]
      @user ||= github_user
      @api ||= @user.api
      @existing_root_repo ||= check_root_repo_status
      if @user.email.nil?
        session[:error] = 'Please confirm your GitHub account first. <br>' \
                          'For more information, please visit:<br>' \
                          '<a href="https://help.github.com/articles/verifying-your-email-address/">' \
                          'https://help.github.com/articles/verifying-your-email-address/</a>'
        redirect '/failure'
      end
    end
  end
end

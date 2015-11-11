require 'sinatra'
require 'sinatra/auth/github'
require './lib/view_helpers'
require 'slim'
require 'faker'
require 'pry' if AppEnv.development?

module BlogPoole
  class App < Sinatra::Base
    enable :sessions
    include ViewHelpers

    set :github_options,       scopes: 'public_repo',
                               secret: ENV['GITHUB_CLIENT_SECRET'],
                               client_id: ENV['GITHUB_CLIENT_ID']

    register Sinatra::Auth::Github

    get '/' do
      slim :index, layout: :default
    end

    get '/new' do
      authenticate!
      setup_user

      slim :new, layout: :default
    end

    post '/create' do
      authenticate!
      setup_user

      str = '<h1>TODO</h1><p>create blog...</p>'
      str << params.inspect
      str << '<br><br>'
      str
      # create_jekyll_blog(params[:site])
    end

    get '/failure' do
      slim :fail, layout: :default
    end

    get '/thanks' do
      slim :thanks, layout: :default
    end

    get '/donate' do
      slim :donate, layout: :default
    end

    # helper methods
    def setup_user
      @user ||= github_user
      @api ||= @user.api
      @existing_root_repo ||= check_root_repo_status
    end

    def check_root_repo_status
      @api.repository?("#{@user.login}/#{@user.login}.github.io")
    end
  end
end

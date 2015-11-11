require 'sinatra'
require 'sinatra/auth/github'
require './lib/view_helpers'
require 'slim'
require 'faker'
require 'yaml'
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
   
    def generate_new_jekyll(user_options)
      Dir.mktmpdir do |dir|
        FileUtils.copy_entry('./lib/clean-jekyll/', dir)
        updated_config = update_config(dir, user_options)
        write_config(updated_config, dir)
        # debug
        new_config = YAML.load_file("#{dir}/_config.yml")
        puts new_config

        # commit_new_jekyll(dir, user_options)
      end
    end

    def update_config(write_dir, user_options)
      config = YAML.load_file("#{write_dir}/_config.yml")
      config.merge(user_options)
    end

    def write_config(config, dir)
      File.open("#{dir}/_config.yml", 'w') do |file| 
        file.write config.to_yaml
      end
    end

    def commit_new_jekyll(_dir, _user_options)
      # TODO: create repository
      #     create commit
      #     push to repo!
      #     profit!
    end
  end
end


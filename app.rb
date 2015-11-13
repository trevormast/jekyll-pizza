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
      generate_new_jekyll(site_params)
      # str = site_params.to_s
      # str << '<br>'
      # str << '<h1> Repo URL: </h1>'
      # str << repo_url(site_params)
      # str
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

    def site_params
      safe_params = {}
      safe_params["title"] = params["site"]["title"]
      safe_params["description"] = params["site"]["description"]
      safe_params["baseurl"] = params["site"]["path"]
      safe_params["url"] = "#{@user.login}.github.io"
      safe_params["github_username"] = "#{@user}"
      safe_params

    end

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

        commit_new_jekyll(dir, user_options)
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

    def commit_new_jekyll(dir, user_options)
      repo_url = repo_url(user_options)
      repo = @api.create_repository(repo_url)
      full_repo_path = repo.full_name

      @api.fork("trevormast/clean-jekyll")

      ### TODO
      ### update _config.yml

      ### edit repo name
      @api.edit_repository("#{user_options["github_username"]}
        /clean-jekyll", :name => "#{user_options["title"]}")
      ### commit

      #@api.create_tree(repo_url(_user_options), _dir) 

      # path = Pathname.new(_dir)
      # path = File.new(_dir)
      # @api.create_contents("trevormast/blerb",
      #            "",
      #            "commitz0r", { :file => path})

      # Dir.foreach(_dir) do |item|
      #   next if item == '.' or item == '..'
      #   scan_folder(item) if File.directory?(directory)

      # end
      @dir = _dir
      scan_folder(_dir, full_repo_path)
        #[{ :path => "_dir", :mode => "040000", :type => "tree"}])
      #     create commit
      #     push to repo!
      #     profit!
    end

    def scan_folder(dir, repo_url)
      Dir.foreach(dir) do |item|
        next if item == '.' or item == '..'
        scan_folder(File.expand_path(item, dir), repo_url) and next if File.directory?(File.expand_path(item, dir))
        create_commit(item, dir, repo_url)
      end
    end

    def create_commit(file, dir, repo_url)
      full_path = File.expand_path(file, dir) 
puts "file: #{file}"
puts "dir: #{dir}"
puts "committing: #{full_path}"
puts "@dir: #{@dir}"
      remote_path = full_path.gsub(@dir+"/","")
puts "REMOTE_PATH: #{remote_path}"
puts @api.create_contents(repo_url,
        remote_path, "commitz0r", { :file => full_path, :branch => 'master' })
    end

    def repo_url(user_options)
      return user_options['url'] if !@existing_root_repo && user_options['baseurl'].blank?
      blog_path(user_options['baseurl']).gsub("/","")
    end

    def blog_path(path)
      return "/" + path unless path[0...1] == "/"
      path
    end
  end
end


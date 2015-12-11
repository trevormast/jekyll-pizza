require 'sinatra'
require 'sinatra/auth/github'
require './lib/view_helpers'
require 'rack/ssl-enforcer'
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

      slim :new, layout: :default
    end

    post '/create' do
      @flash ||= []
      authenticate!
      setup_user
      @failures ||= 0

      begin
        # TODO: improve validations
        if @api.repository?(user_repo_path(site_params))
          @failures += 1
          redirect "/new?error=Oops, that repository already exists, pick a new path!&failures=#{@failures}"
        end

        @repo = create_jekyll_repo(site_params)
        @site_url = full_repo_url(site_params)
        check_build_status
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

    def check_root_repo_status
      @api.repository?("#{@user.login}/#{@user.login}.github.io")
    end

    def create_jekyll_repo(user_options)
      Dir.mktmpdir do |dir|
        copy_clean_jekyll(dir)
        @updated_config = update_config(dir, user_options)
        write_config(@updated_config, dir)
        commit_new_jekyll(dir, user_options)
      end
    end

    def update_config(write_dir, user_options)
      config = YAML.load_file("#{write_dir}/_config.yml")
      config.merge(user_options)
    end

    def write_config(config, dir)
      File.open("#{dir}/_config.yml", 'w') do |file| 
        file.write config.to_yaml.to_s.gsub("---\n", '') # squash pesky ---
      end
    end

    def commit_new_jekyll(dir, user_options)
      repo_url = repository_url(user_options)
      repo = @api.create_repository(repo_url, auto_init: true)
      full_repo_path = repo.full_name
      @dir = dir

      if @root_repo
        @ref = 'heads/master'
        sha_latest_commit = @api.ref(full_repo_path, @ref).object.sha
      else
        @ref = 'heads/gh-pages'
        sha_latest_commit = @api.ref(full_repo_path, 'heads/master').object.sha
        sha_latest_commit = @api.create_ref(full_repo_path, @ref, sha_latest_commit).object.sha
      end

      sha_base_tree = @api.commit(full_repo_path, sha_latest_commit).commit.tree.sha
      
      last_sha = scan_folder(dir, full_repo_path, sha_latest_commit, sha_base_tree)

      @api.update_branch(full_repo_path, @ref.gsub('heads/', ''), last_sha)
      @api.edit_repository(full_repo_path,     description: 'A Jekyll-powered site generated by jekyll:pizza:pizza',
                                               homepage: full_repo_url(user_options),
                                               default_branch: ((@root_repo == true) ? 'master' : 'gh-pages'))

      repo
    end

    def scan_folder(dir, repo_url, sha_latest_commit, sha_base_tree)
      @latest_sha = sha_latest_commit
      Dir.foreach(dir) do |item|
        next if item == '.' || item == '..'
        full_path = File.expand_path(item, dir)
        puts "DIR! #{full_path}" if File.directory?(full_path) 
        scan_folder(full_path, repo_url, @latest_sha, sha_base_tree) if File.directory?(full_path)
        next if File.directory?(full_path)

        sha_latest_commit = @api.ref(repo_url, @ref).object.sha
        sha_base_tree = @api.commit(repo_url, sha_latest_commit).commit.tree.sha

        sha_new_commit = create_commit(item, dir, repo_url, sha_latest_commit, sha_base_tree)
        @latest_sha = sha_new_commit
      end
      @latest_sha
    end

    def create_commit(file, dir, repo_url, sha_latest_commit, sha_base_tree)
      full_path = File.expand_path(file, dir)
      remote_path = full_path.gsub(@dir + '/', '')
      blob_sha = @api.create_blob(repo_url, Base64.encode64(File.read(full_path)), 'base64')
      sha_new_tree = @api.create_tree(repo_url, 
                                      [{ path: remote_path, 
                                         mode: '100644', 
                                         type: 'blob', 
                                         sha: blob_sha }], 
                                      base_tree: sha_base_tree).sha
      commit_message = "Creates #{remote_path}"
      puts "committing: #{full_path}"
      sha_new_commit = @api.create_commit(repo_url, commit_message, sha_new_tree, sha_latest_commit).sha
      updated_ref = @api.update_ref(repo_url, @ref, sha_new_commit)
      sha_new_commit
    end

    def user_repo_path(safe_params)
      @user.login + '/' + repository_url(safe_params)
    end

    def repository_url(safe_params)
      if params['site']['path'].blank?
        @root_repo = true
        return safe_params['url'].gsub('https://', '') 
      end
      blog_path(safe_params['baseurl']).gsub('https://', '').delete('/')
    end

    def full_repo_url(safe_params)
      proto = 'https://'
      return proto + repository_url(safe_params) if @root_repo
      proto + @user.login + '.github.io/' + repository_url(safe_params) + '/'
    end

    def blog_path(path)
      return '/' + path unless path[0...1] == '/'
      path
    end

    def copy_clean_jekyll(temp_dir)
      path = theme_selection(site_params)
      FileUtils.copy_entry("#{path}", temp_dir)
    end

    def theme_selection(safe_params)
      return "./lib/#{safe_params['theme']}/"
    end

    def branch_name
      return "gh-pages" unless params['site']['path'].blank?
      return "master"
    end

    def final_commit(branch_name)
      @api.create_contents("#{@repo[:full_name]}",
                            "/humans.txt",
                            "Final Commit",
                            "Thank you for using jekyll.pizza!",
                            :branch => "#{branch_name}")
      puts "FINAL COMMIT"
    end

    def check_build_status
      build_status = @api.pages("#{@repo[:full_name]}")[:status]
      while build_status != "built"
        final_commit(branch_name)
        sleep(5)
      end
    end

  end
end

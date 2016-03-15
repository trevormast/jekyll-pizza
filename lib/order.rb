require './lib/path_error'

module JekyllPizza 
  class Order 
    attr_reader :user, :root_repo, :repo_url
    def initialize(args)          
      @user = args[:user]
      @params = args[:params]
      @root_repo = nil
      @repo_url = repository_url
    end

    def site_params
      # TODO: validate safe_params
      safe_params = {}
      safe_params['title'] = @params['site']['title'] unless @params['site']['title'].blank?
      safe_params['description'] = @params['site']['description'] unless @params['site']['description'].blank?

      # TODO: improve this logic
      safe_params['baseurl'] = sanitized_path
      safe_params['baseurl'] = '/' + safe_params['baseurl'] unless safe_params['baseurl'].match(/^\//) || @params['site']['path'].blank?

      safe_params['url'] = "#{@user.login}.github.io"
      safe_params['github_username'] = @user.login
      safe_params['theme'] = @params['site']['theme']

      @safe_params = safe_params
    end

    def user_repo_path
      @user.login + '/' + repository_url
    end

    private

    def sanitized_path
      if @params['site']['path'].match(/\A\/?[a-z|0-9][a-z|0-9|\-|\_]*\z/) || @path == ''
        return @params['site']['path']
      else
        fail PathError
      end
    end

    def repository_url
      if @params['site']['path'].blank?
        @root_repo = true
        return @safe_params['url'].gsub('https://', '') 
      end
      @repo_url = blog_path.gsub('https://', '').delete('/')
    end

    def blog_path
      return '/' + site_params['baseurl'] unless site_params['baseurl'][0...1] == '/'
      site_params['baseurl']
    end
  end
end

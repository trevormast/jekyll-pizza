
require './lib/recipe'
require './lib/oven'
require './lib/path_error'

module JekyllPizza 
  class Delivery 
    def initialize(user, 
                   params, 
                   recipe = Recipe.new,
                   oven = Oven.new)
      @user = user
      @params = params
      @opts = {}
      @recipe = recipe
      @oven = oven
      @safe_params = site_params(@params)
    end

    def run
      load_opts

      @dir = @recipe.read(@safe_params)
      @site_info = @oven.bake(@user, @dir, @opts)
    end

    def load_opts
      @opts[:root_repo] = @root_repo
      @opts[:repo_url] = @repo_url
      @opts[:safe_params] = @safe_params
    end

    def site_params(params)
      # TODO: validate safe_params

      safe_params = {}
      safe_params['title'] = params['site']['title'] unless params['site']['title'].blank?
      safe_params['description'] = params['site']['description'] unless params['site']['description'].blank?

      # TODO: improve this logic
      safe_params['baseurl'] = sanitize_path(params['site']['path'])
      safe_params['baseurl'] = '/' + safe_params['baseurl'] unless safe_params['baseurl'].match(/^\//) || params['site']['path'].blank?

      safe_params['url'] = "#{@user.login}.github.io"
      safe_params['github_username'] = @user.login
      safe_params['theme'] = params['site']['theme']

      safe_params
    end

    def sanitize_path(path)
      if path.match(/\A\/?[a-z|0-9][a-z|0-9|\-|\_]*\z/) || path == ''
        return path
      else
        fail PathError
      end
    end

    def repository_url
      if @params['site']['path'].blank?
        @root_repo = true
        return @safe_params['url'].gsub('https://', '') 
      end
      @repo_url = blog_path(@safe_params['baseurl']).gsub('https://', '').delete('/')
    end

    def blog_path(path)
      return '/' + path unless path[0...1] == '/'
      path
    end

    def user_repo_path
      @user.login + '/' + repository_url
    end
  end
end

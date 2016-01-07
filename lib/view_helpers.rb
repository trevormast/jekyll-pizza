module JekyllPizza
  module ViewHelpers
    include AppEnv
    def root_url
      AppEnv.protocol + '://' + hostname + port + '/'
    end

    def hostname
      AppEnv.development? ? 'localhost' : (ENV['hostname'] || 'fresh.jekyll.pizza')
    end

    def port
      AppEnv.development? ? ':' + (ENV['RACK_PORT'] || '9292') : ''
    end

    def current_path
      request.path_info
    end
  end
end

module JekyllPizza
  class Recipe
    attr_reader :dir
    def initialize(safe_params)
      @safe_params = safe_params
      @dir = Dir.mktmpdir
      @theme = @safe_params['theme']
      @theme_path = "./lib/themes/#{@theme}"

      copy_jekyll
      @updated_config = update_config
      write_config
    end

    def copy_jekyll
      FileUtils.copy_entry("#{@theme_path}", @dir)
    end

    def update_config
      config = YAML.load_file("#{@dir}/_config.yml")
      config.merge(@safe_params)
    end

    def write_config
      File.open("#{@dir}/_config.yml", 'w') do |file| 
        file.write @updated_config.to_yaml.to_s.gsub("---\n", '') # squash pesky ---
      end
    end
  end
end

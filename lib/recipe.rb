module JekyllPizza
  class Recipe
    attr_reader :safe_params, :theme_path, :dir
    def initialize(safe_params)
      @safe_params = safe_params
      @theme = @safe_params["theme"]
      @theme_path = "./lib/themes/#{@theme}"
      @dir = Dir.mktmpdir
    end

    def read
      copy_jekyll(@dir)
      @updated_config = update_config(@dir, @safe_params)
      write_config(@updated_config, @dir)
      @dir
    end

    def copy_jekyll(temp_dir)
      FileUtils.copy_entry("#{@theme_path}", temp_dir)
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
  end
end

module JekyllPizza
  class TasteTest
    def run(args)
      @user = args[:user]
      @api = @user
      @site_info = args[:site_info]
      @repo = @site_info[:repo]
      @branch_name = @site_info[:branch_name]
      @full_name = @repo[:full_name]
      check_build_status
    end

    def update_readme(builds)
      readme_info = @api.contents("#{@full_name}", path: '/README.md')
      @api.update_contents("#{@full_name}",
                           '/README.md',
                           'New build',
                           "#{readme_info[:sha]}",
                           "#Thank you for using Jekyll.Pizza#{'!' * (1 + builds)}",
                           branch: "#{@branch_name}")
      puts 'Starting new build'
    end

    def check_build_status(count = 0)
      builds = count
      @build_status = @api.pages("#{@full_name}")[:status]
      if builds == 5
        puts "exceeded build limit: errored #{builds} times."
        redirect '/new?error=Oops, Something went wrong!'
      end
      
      case @build_status 
      when 'building'
        puts "Build status: #{@build_status}"
        sleep(5) # Give GHPages a chance to catch up with api requests
        check_build_status(builds)
      when 'errored'
        puts "Build status: #{@build_status}"
        update_readme(builds)
        builds += 1
        check_build_status(builds)
      else
        puts 'BUILD COMPLETE!'
      end
    end
  end 
end

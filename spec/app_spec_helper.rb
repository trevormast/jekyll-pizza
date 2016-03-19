# Removes 5s of sleep when checking GHPages build 
class JekyllPizza::TasteTest
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

# Calls synchronous job for testability
class JekyllPizza::App
  def create_blog(order)
    @site_info = CommitJob.new.perform(order)
  end
end

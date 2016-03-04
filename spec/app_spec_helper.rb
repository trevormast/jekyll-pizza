class JekyllPizza::Oven
  def check_build_status(count = 0)
    builds = count
    build_status = @api.pages("#{@repo[:full_name]}")[:status]
    if builds == 5
      puts "exceeded build limit: errored #{builds} times."
      redirect '/new?error=Oops, Something went wrong!'
    end
    
    case build_status 
    when 'building'
      puts "Build status: #{build_status}"
      check_build_status(builds)
    when 'errored'
      puts "Build status: #{build_status}"
      update_readme(branch_name, builds)
      builds += 1
      check_build_status(builds)
    else
      puts 'BUILD COMPLETE!'
    end
  end
end

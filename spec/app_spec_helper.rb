# Removes 5 second sleep for testing
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

# Performs synchronous job for testing
class JekyllPizza::App
  def create_blog(token, params)
    CommitWorker.new.perform(token, params)
  end
end

# user token is unavailable in testing
class CommitWorker
  def perform(_token, params)
    client = Sinatra::Auth::Github::Test::Helper::User.make.api
    order = JekyllPizza::Order.new(user: client,
                                   params: params)
    
    JekyllPizza::Delivery.new(order: order, 
                              directory: JekyllPizza::Recipe.new(order.site_params).dir,
                              repo: JekyllPizza::Oven.new, 
                              build_status: JekyllPizza::TasteTest.new).run
  end
end  

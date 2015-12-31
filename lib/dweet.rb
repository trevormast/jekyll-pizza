module BlogPoole
  module DweetPizza
    def dweet_login
      thing = Dweet::Thing.new 'JekyllPizzaBlogs'
      begin
        count = thing.last.content['logins']
      rescue NoMethodError
        count = 0
      end
      count ||= 0
      status = Dweet::Dweet.new
      status.content = { logins: (count + 1) }
      result_status = thing.publish status
      puts "Dweeted: #{result_status}"
    end

    def dweet_creation
      thing = Dweet::Thing.new 'JekyllPizzaBlogCreations'
      begin
        count = thing.last.content['created_success']
      rescue NoMethodError
        count = 0
      end

      begin
        theme_count = thing.last.content[site_params['theme']]
      rescue NoMethodError
        theme_count = 0
      end

      count ||= 0
      theme_count ||= 0

      status = Dweet::Dweet.new
      status.content = { 
        created_success: (count + 1),
        site_params['theme'] => (theme_count + 1)
      }
      result_status = thing.publish status
      puts "Dweeted: #{result_status}"
    end
  end
end

require 'sucker_punch'
require './lib/delivery'
require './lib/recipe'
require './lib/oven'
require './lib/taste_test'

unless ENV['RACK_ENV'] == 'production'
  SuckerPunch.shutdown_timeout = 1500 
end

class CommitJob
  include SuckerPunch::Job

  def perform(order)
    JekyllPizza::Delivery.new(order: order, 
                 directory: JekyllPizza::Recipe.new(order.site_params).dir,
                 repo: JekyllPizza::Oven.new, 
                 build_status: JekyllPizza::TasteTest.new).run
  end
end


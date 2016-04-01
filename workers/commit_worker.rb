require 'sidekiq'
require 'sidekiq_status' if ENV['RACK_ENV'] != 'test'
require 'octokit'
require 'active_support'
require 'active_support/core_ext/object/blank'
require './lib/order'
require './lib/delivery'
require './lib/recipe'
require './lib/oven'
require './lib/taste_test'
require 'pry'

# Sidekiq.configure_server do |config|
#   if ENV['RACK_ENV'] == 'production'
#     config.redis = { url: 'redis://redistogo:df7be5588f72a6fe0e7b93dfb97f1464@squawfish.redistogo.com:9248/' }
#   end
# end

# Sidekiq.configure_client do |config|
#   if ENV['RACK_ENV'] == 'production'
#     config.redis = { url: 'redis://redistogo:df7be5588f72a6fe0e7b93dfb97f1464@squawfish.redistogo.com:9248/' }
#   end
# end

class CommitWorker
  include Sidekiq::Worker
  include SidekiqStatus::Worker if ENV['RACK_ENV'] != 'test'
  # sidekiq_options retry: false

  def perform(token, params)
    client = Octokit::Client.new(access_token: token)

    order = JekyllPizza::Order.new(user: client,
                                   params: params)


    JekyllPizza::Delivery.new(order: order, 
                              directory: JekyllPizza::Recipe.new(order.site_params).dir,
                              repo: JekyllPizza::Oven.new, 
                              build_status: JekyllPizza::TasteTest.new).run
  end
end

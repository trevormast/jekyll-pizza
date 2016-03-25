require 'sidekiq'
require 'octokit'
require 'active_support'
require 'active_support/core_ext/object/blank'
require './lib/order'
require './lib/delivery'
require './lib/recipe'
require './lib/oven'
require './lib/taste_test'
require 'pry'

class CommitWorker
  include Sidekiq::Worker

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

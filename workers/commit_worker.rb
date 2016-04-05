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

class CommitWorker
  include Sidekiq::Worker if ENV['RACK_ENV'] == 'test'
  include SidekiqStatus::Worker if ENV['RACK_ENV'] != 'test'
  # sidekiq_options retry: false

  def perform(token, params)
    self.total = 100

    at(0, 'Starting...')
    client = Octokit::Client.new(access_token: token)

    at(30, 'Taking Order...')
    order = JekyllPizza::Order.new(user: client,
                                   params: params)

    at(60, 'Committing Blog...')
    @delivery = JekyllPizza::Delivery.new(order: order,
                                          directory: JekyllPizza::Recipe.new(order.site_params).dir,
                                          repo: JekyllPizza::Oven.new,
                                          build_status: JekyllPizza::TasteTest.new).run

    at(100, 'Complete!')
  end
end

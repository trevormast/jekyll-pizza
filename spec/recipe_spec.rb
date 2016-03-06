require 'rspec'
require 'sinatra/auth/github/test/test_helper'
require 'pry'

require File.expand_path '../../lib/recipe.rb', __FILE__
require File.expand_path '../../lib/order.rb', __FILE__

class JekyllPizza::Recipe
  attr_reader :theme, :theme_path
end

describe 'Recipe' do
  before(:each) do
    @user = Sinatra::Auth::Github::Test::Helper::User.make
    @params =  { 'site' => { 'title' => 'test title', 'description' => 'test desc', 
                             'root_url' => 'test_user.github.io', 
                             'path' => 'deliverytest', 'theme' => 'clean-jekyll' } }
    @order = JekyllPizza::Order.new(user: @user, params: @params)
    # @theme = 'clean-jekyll'

    @recipe = JekyllPizza::Recipe.new(@order.site_params)
  end
    
  it 'should return correct theme path' do
    expect(@recipe.theme_path).to eq('./lib/themes/clean-jekyll')
  end

  it 'should update config.yml' do
    expect(@recipe).to respond_to(:update_config)
  end

  it 'should write user data to config' do
    expect(@recipe).to respond_to(:write_config)
  end
end

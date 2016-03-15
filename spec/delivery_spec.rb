require 'spec_helper'
require 'githubstubs'
require File.expand_path '../../lib/delivery.rb', __FILE__
require File.expand_path '../../lib/oven.rb', __FILE__
require File.expand_path '../../lib/recipe.rb', __FILE__
require File.expand_path '../../lib/taste_test.rb', __FILE__
require 'app_spec_helper'
require 'pry'

describe 'Delivery' do
  before do
    
    include GitHubStubs

    GitHubStubs.valid_stubs
    @user = Sinatra::Auth::Github::Test::Helper::User.make
    @params =  { 'site' => { 'title' => '', 'description' => '', 'root_url' => 'user.github.io', 'path' => 'path', 'theme' => 'clean-jekyll' } }

    @order = JekyllPizza::Order.new(user: @user, params: @params)
    @delivery = JekyllPizza::Delivery.new(order: @order, 
                                          directory: JekyllPizza::Recipe.new(@order.site_params).dir,
                                          repo: JekyllPizza::Oven.new, 
                                          build_status: JekyllPizza::TasteTest.new)
  end

  it 'returns blog information' do
    # expect(@delivery.send(:create_blog)).to have_key(:build).and have_key(:repo)
    expect(@delivery.run).to have_key(:repo).and have_key(:build)
  end
end


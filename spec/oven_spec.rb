require 'rspec'
require 'spec_helper'
require 'sinatra/auth/github/test/test_helper'
require 'githubstubs'
# require 'app_spec_helper'
require 'pry'

require File.expand_path '../../lib/oven.rb', __FILE__
require File.expand_path '../../lib/order.rb', __FILE__

class JekyllPizza::Oven
  attr_reader :user, :dir, :safe_params, :repo
end

describe 'Oven' do 
  before do
    include GitHubStubs

    GitHubStubs.valid_stubs

    @user = Sinatra::Auth::Github::Test::Helper::User.make
    @params =  { 'site' => { 'title' => 'test title', 'description' => 'test desc', 
                             'root_url' => 'test_user.github.io', 
                             'path' => 'deliverytest', 'theme' => 'clean-jekyll' } }
    @order = JekyllPizza::Order.new(user: @user, params: @params)
                                                                
    @dir = Dir.mktmpdir

    @oven = JekyllPizza::Oven.new

    @oven.run(order: @order, dir: @dir)

    allow(@oven).to receive(:commit_new_jekyll)

    # TODO: stub the commit_new_jekyll method to stop ext requests
    
  end

  it 'has a user' do
    expect(@oven.user.attribs).to include('login')
  end

  # it 'has a full repo name' do
  #   expect(@oven.repo).to respond_to(:full_name)
  # end
end

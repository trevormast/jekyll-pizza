require 'rspec'
require 'sinatra/auth/github/test/test_helper'
require 'pry'

require File.expand_path '../../lib/delivery.rb', __FILE__

class JekyllPizza::Delivery
  attr_reader :user, :safe_params
end

describe 'Delivery' do
  before do
    @user = Sinatra::Auth::Github::Test::Helper::User.make
    @site_params = { 'title' => 'test title', 'description' => 'test desc', 
                     'url' => 'test_user.github.io',
                     'baseurl' => '/deliverytest', 'theme' => 'clean-jekyll',
                     'github_username' => 'test_user' } 

    @delivery = JekyllPizza::Delivery.new(@user, @site_params)
  end
  
  it 'should be able to run' do 
    expect(@delivery).to respond_to(:run)
  end
  it 'should have a user' do
    expect(@delivery.user.attribs).to include('login')
  end

  it 'should have a safe_params hash' do
    expect(@delivery.safe_params).to include('title' => 'test title')
    expect(@delivery.safe_params).to include('description' => 'test desc')
    expect(@delivery.safe_params).to include('baseurl' => '/deliverytest')
    expect(@delivery.safe_params).to include('url' => 'test_user.github.io')
    expect(@delivery.safe_params).to include('github_username' => 'test_user')
  end
end

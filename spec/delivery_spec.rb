require 'rspec'
require 'sinatra/auth/github/test/test_helper'
require 'pry'

require File.expand_path '../../lib/delivery.rb', __FILE__

class JekyllPizza::Delivery
  attr_reader :user, :safe_params, :opts
end

describe 'Delivery' do
  context 'with allowed path name' do
    before do
      @user = Sinatra::Auth::Github::Test::Helper::User.make
      @params =  { 'site' => { 'title' => 'test title', 'description' => 'test desc', 
                               'root_url' => 'test_user.github.io', 
                               'path' => 'deliverytest', 'theme' => 'clean-jekyll' } }

      @delivery = JekyllPizza::Delivery.new(@user, @params)
    end
    
    it 'should be able to run' do 
      expect(@delivery).to respond_to(:run)
    end
    it 'should have a user' do
      expect(@delivery.user.attribs).to include('login')
    end

    it 'loads opts hash' do
      @delivery.repository_url
      @delivery.load_opts

      expect(@delivery.opts).to include(root_repo: nil)
      expect(@delivery.opts).to include(repo_url: 'deliverytest')
      expect(@delivery.opts).to include(:safe_params)
    end

    it 'should have a safe_params hash' do
      expect(@delivery.safe_params).to include('title' => 'test title')
      expect(@delivery.safe_params).to include('description' => 'test desc')
      expect(@delivery.safe_params).to include('baseurl' => '/deliverytest')
      expect(@delivery.safe_params).to include('url' => 'test_user.github.io')
      expect(@delivery.safe_params).to include('github_username' => 'test_user')
    end
  end

  context 'with prohibited path name' do
    it 'raises PathError' do
      @user = Sinatra::Auth::Github::Test::Helper::User.make
      @params =  { 'site' => { 'title' => 'test title', 'description' => 'test desc', 
                               'root_url' => 'test_user.github.io', 
                               'path' => 'delivery test', 'theme' => 'clean-jekyll' } }

      expect { JekyllPizza::Delivery.new(@user, @params) }.to raise_error(PathError)
    end
  end
end

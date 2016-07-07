require 'rspec'
require 'sinatra/auth/github/test/test_helper'
require 'pry'

describe 'Order' do
  context 'with allowed path name' do
    before do
      @user = Sinatra::Auth::Github::Test::Helper::User.make
      @params =  { 'site' => { 'title' => 'test title', 'description' => 'test desc',
                               'root_url' => 'test_user.github.io',
                               'path' => 'deliverytest', 'theme' => 'clean-jekyll' } }

      @order = JekyllPizza::Order.new(user: @user, params: @params)
    end

    it 'should have a user' do
      expect(@order.user.attribs).to include('login')
    end

    it 'should sanitize params' do
      expect(@order.site_params).to include('title' => 'test title')
      expect(@order.site_params).to include('description' => 'test desc')
      expect(@order.site_params).to include('baseurl' => '/deliverytest')
      expect(@order.site_params).to include('url' => 'test_user.github.io')
      expect(@order.site_params).to include('github_username' => 'test_user')
    end
  end

  context 'with prohibited path name' do
    it 'raises PathError' do
      @user = Sinatra::Auth::Github::Test::Helper::User.make
      @params =  { 'site' => { 'title' => 'test title', 'description' => 'test desc',
                               'root_url' => 'test_user.github.io',
                               'path' => 'delivery test', 'theme' => 'clean-jekyll' } }
      expect { JekyllPizza::Order.new(user: @user, params: @params) }.to raise_error(PathError)
    end
  end

  context 'with no given path name' do
    it 'returns correct repository_url' do
      @user = Sinatra::Auth::Github::Test::Helper::User.make
      @params =  { 'site' => { 'title' => 'test title', 'description' => 'test desc',
                               'root_url' => 'test_user.github.io',
                               'path' => '', 'theme' => 'clean-jekyll' } }
      @order = JekyllPizza::Order.new(user: @user, params: @params)

      expect(@order.send(:repository_url)).to eq('test_user.github.io')
    end
  end
end

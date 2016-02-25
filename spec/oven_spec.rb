require 'rspec'
require 'spec_helper'
require 'sinatra/auth/github/test/test_helper'
require 'pry'

require File.expand_path '../../lib/oven.rb', __FILE__

describe 'Oven' do 
  before do
    @user = Sinatra::Auth::Github::Test::Helper::User.make
    @opts = { root_repo: nil, repo_url: '/deliverytest', safe_params: { 'title' => 'test title', 'description' => 'test desc', 
                                                                        'baseurl' => '/deliverytest',
                                                                        'url' => 'test_user.github.io',
                                                                        'github_username' => 'test_user' } }
    @dir = '/var/folders/nw/90qc2bxx12j6cg94870gcl4r0000gn/T/d20160222-19793-1rzm66u'

    @oven = JekyllPizza::Oven.new(@user, @dir, @opts)
  end

  it 'returns a user' do
    expect(@oven.user.attribs).to include('login')
  end

  it 'returns a directory path' do
    expect(@oven.dir).to eq('/var/folders/nw/90qc2bxx12j6cg94870gcl4r0000gn/T/d20160222-19793-1rzm66u')
  end

  it 'should return correct parameters' do
    expect(@oven.safe_params).to include('title' => 'test title')
    expect(@oven.safe_params).to include('description' => 'test desc')
    expect(@oven.safe_params).to include('baseurl' => '/deliverytest')
    expect(@oven.safe_params).to include('url' => 'test_user.github.io')
    expect(@oven.safe_params).to include('github_username' => 'test_user')
  end
end

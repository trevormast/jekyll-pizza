require 'rspec'
require 'spec_helper'
require 'sinatra/auth/github/test/test_helper'
require 'githubstubs'
# require 'app_spec_helper'
require 'pry'

require File.expand_path '../../lib/oven.rb', __FILE__
require File.expand_path '../../lib/order.rb', __FILE__

class JekyllPizza::Oven
  attr_reader :api, :dir, :safe_params, :repo
end

describe 'Oven' do 
  before do
    include GitHubStubs

    GitHubStubs.valid_stubs

    @user = Sinatra::Auth::Github::Test::Helper::User.make.api
    @params =  { 'site' => { 'title' => 'test title', 'description' => 'test desc', 
                             'root_url' => 'test_user.github.io', 
                             'path' => 'deliverytest', 'theme' => 'clean-jekyll' } }
    @order = JekyllPizza::Order.new(user: @user, params: @params)
                                                                
    @dir = Dir.mktmpdir

    @oven = JekyllPizza::Oven.new

    @oven.run(order: @order, dir: @dir)

    # allow(@oven).to receive(:commit_new_jekyll)

    # TODO: stub the commit_new_jekyll method to stop ext requests
    
  end

  it 'has a user' do
    expect(@oven.api.login).to include('test_user')
  end

  it 'has a full repo name' do
    expect(@oven.repo).to respond_to(:full_name)
  end

  it 'creates a repo info struct' do
    repo = @oven.create_repo_object(@order.user.create_repository(@repo_url, auto_init: true))

    expect(repo.full_repo_path).to eq('test_user/path')
    expect(repo.sha_latest_commit).to eq('c0879ec586f927218eb41e5e51578afc0e71cd10')
    expect(repo.sha_base_tree).to eq('4dd7b0f95a42943a3642007bde90e3f652689b73')
  end
end

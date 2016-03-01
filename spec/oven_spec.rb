require 'rspec'
require 'spec_helper'
require 'sinatra/auth/github/test/test_helper'
require 'githubstubs'
require 'pry'

require File.expand_path '../../lib/oven.rb', __FILE__

class JekyllPizza::Oven
  attr_reader :user, :dir, :safe_params, :repo
end

describe 'Oven' do 
  before do
    include GitHubStubs

    GitHubStubs.valid_stubs

    @user = Sinatra::Auth::Github::Test::Helper::User.make
    @opts = { root_repo: nil, repo_url: '/path', safe_params: { 'title' => 'test title', 'description' => 'test desc', 
                                                                'baseurl' => '/deliverytest',
                                                                'url' => 'test_user.github.io',
                                                                'github_username' => 'test_user' } }
    @dir = Dir.mktmpdir

    @oven = JekyllPizza::Oven.new

    @oven.bake(@user, @dir, @opts)

    allow(@oven).to receive(:commit_new_jekyll).with(@dir)
    allow(@oven).to receive(:check_build_status)
    # TODO: stub the commit_new_jekyll method to stop ext requests
    
  end

  it 'has a user' do
    expect(@oven.user.attribs).to include('login')
  end

  it 'has a full repo name' do
    expect(@oven.repo).to respond_to(:full_name)
  end

  # it 'has a directory path' do
  #   expect(@oven.dir).to eq(@dir)
  # end
end

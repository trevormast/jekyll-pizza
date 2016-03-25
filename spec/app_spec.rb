require 'spec_helper'
require 'sinatra/auth/github/test/test_helper'
require 'json'
require 'githubstubs'
# require File.expand_path '../../lib/taste_test.rb', __FILE__
require 'app_spec_helper'

describe 'App' do
  include Warden::Test::Helpers

  after do
    Warden.test_reset!
  end

  describe "GET '/'" do
    it 'loads homepage' do
      get '/'
      expect(last_response).to be_ok
    end

    it 'loads analytics snippet' do
      get '/'
      expect(last_response.body).to include('https://www.google-analytics.com/analytics.js')
    end
  end
  
  describe "GET '/new'" do
    it 'loads new page' do
      login_as Sinatra::Auth::Github::Test::Helper::User.make
      
      stub_request(:get, 'https://api.github.com/repos/test_user/test_user.github.io').
        with(headers: { 'Accept' => 'application/vnd.github.v3+json', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Octokit Ruby Gem 4.1.1' }).
        to_return(status: 200, body: '', headers: {})
      get '/new'
      expect(last_response).to be_ok
      expect(last_response.body).to include('test_user.github.io')
    end
  end

  describe "GET '/create'" do
    it 'redirects to /new page' do
      get '/create'
      expect(last_response).to be_redirect
      # follow_redirect!
      # expect(last_request.path).to eq('/new')
    end
  end

  # describe "POST '/create'" do
  #   before do
  #     login_as Sinatra::Auth::Github::Test::Helper::User.make

  #     include GitHubStubs

  #     GitHubStubs.valid_stubs
      
  #     params =  { 'site' => { 'title' => '', 'description' => '', 'root_url' => 'user.github.io', 'path' => 'path', 'theme' => 'clean-jekyll' } }
      
  #     post 'create', params
  #   end

  #   it 'creates me a jekyll blog' do
  #     expect(a_request(:get, 'https://api.github.com/repos/test_user/test_user.github.io')).to have_been_made.at_least_once
  #     expect(a_request(:get, 'https://api.github.com/repos/test_user/path')).to have_been_made.at_least_once
  #     expect(a_request(:post, 'https://api.github.com/user/repos')).to have_been_made.at_least_once
  #     expect(a_request(:get, 'https://api.github.com/repos/test_user/path/git/refs/heads/master')).to have_been_made.at_least_once
  #     expect(a_request(:post, 'https://api.github.com/repos/test_user/path/git/refs')).to have_been_made.at_least_once
  #     expect(a_request(:get, 'https://api.github.com/repos/test_user/path/commits/c0879ec586f927218eb41e5e51578afc0e71cd10')).to have_been_made.at_least_once
  #     expect(a_request(:get, 'https://api.github.com/repos/test_user/path/git/refs/heads/feature')).to have_been_made.at_least_once
  #     expect(a_request(:post, 'https://api.github.com/repos/test_user/path/git/blobs')).to have_been_made.at_least_once
  #     expect(a_request(:post, 'https://api.github.com/repos/test_user/path/git/trees')).to have_been_made.at_least_once
  #     expect(a_request(:post, 'https://api.github.com/repos/test_user/path/git/commits')).to have_been_made.at_least_once
  #     expect(a_request(:patch, 'https://api.github.com/repos/test_user/path/git/refs/heads/feature')).to have_been_made.at_least_once
  #     expect(a_request(:patch, 'https://api.github.com/repos/test_user/path')).to have_been_made.at_least_once
  #   end

  #   it 'displays correct site info' do
  #     expect(last_response.body).to include('https://github.com/test_user/path')
  #     expect(last_response.body).to include('https://test_user.github.io/path')
  #   end
  # end

  describe "POST '/create'" do
    it 'calls CommitWorker' do
      
    end
  end
  describe "GET '/failure'" do
    it 'gets the /failure page' do
      get '/failure'

      expect(last_response).to be_ok
      expect(last_response.body).to include('Error')
    end
  end

  describe "GET '/thanks'" do
    it 'gets the /thanks page' do
      get '/thanks'

      expect(last_response).to be_ok
      expect(last_response.body).to include('Thank')
    end
  end

  describe "GET '/attribution'" do
    it 'gets the /attribution page' do
      get '/attribution'

      expect(last_response).to be_ok
      # expect(last_response.body).to include("Possible")
    end
  end

  describe "GET '/donate'" do
    it 'gets the /donate page' do
      get '/donate'

      expect(last_response).to be_ok
      expect(last_response.body).to include('Donate')
    end
  end
end

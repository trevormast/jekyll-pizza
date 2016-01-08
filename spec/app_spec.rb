require 'spec_helper'
require 'sinatra/auth/github/test/test_helper'
require 'json'
require 'githubstubs'

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
      follow_redirect!
      expect(last_request.path).to eq('/new')
    end
  end

  describe "POST '/create'" do
    it 'creates me a jekyll blog' do
      login_as Sinatra::Auth::Github::Test::Helper::User.make

      include GitHubStubs

      GitHubStubs.valid_stubs
      
      params =  { 'site' => { 'title' => '', 'description' => '', 'root_url' => 'user.github.io', 'path' => 'path', 'theme' => 'clean-jekyll' } }
      
      post 'create', params
      # binding.pry
      # expect(site_params).to include("title")

      expect(WebMock).to have_requested(:get, 'https://api.github.com/repos/test_user/test_user.github.io')
      expect(WebMock).to have_requested(:get, 'https://api.github.com/repos/test_user/path')
      expect(WebMock).to have_requested(:post, 'https://api.github.com/user/repos')
      # expect(WebMock).to have_requested(:get, "https://api.github.com/repos/test_user/path/git/refs/heads/master")
      # expect(WebMock).to have_requested(:post, "https://api.github.com/repos/test_user/path/git/refs")
      # expect(WebMock).to have_requested(:get, "https://api.github.com/repos/test_user/path/commits/c0879ec586f927218eb41e5e51578afc0e71cd10")
      # expect(WebMock).to have_requested(:get, "https://api.github.com/repos/test_user/path/git/refs/heads/gh-pages")
      # expect(WebMock).to have_requested(:post, "https://api.github.com/repos/test_user/path/git/blobs")
      # expect(WebMock).to have_requested(:post, "https://api.github.com/repos/test_user/path/git/trees")
      # expect(WebMock).to have_requested(:post, "https://api.github.com/repos/test_user/path/git/commits")
      # expect(WebMock).to have_requested(:patch, "https://api.github.com/repos/test_user/path/git/refs/heads/gh-pages")
      # expect(WebMock).to have_requested(:patch, "https://api.github.com/repos/test_user/path")
      expect(WebMock).to have_requested(:get, 'https://api.github.com/repos/test_user/path/pages')

      expect(last_response).to be_ok
    end	

    describe "GET '/failure'" do
      it 'gets the /failure page' do
        get '/failure'
  
        expect(last_response).to be_ok
      end
  
      describe "GET '/thanks'" do
        it 'gets the /thanks page' do
          get '/thanks'
    
          expect(last_response).to be_ok
        end
      end
  
      describe "GET '/attribution'" do
        it 'gets the /attribution page' do
          get '/attribution'
    
          expect(last_response).to be_ok
        end
      end
  
      describe "GET '/donate'" do
        it 'gets the /donate page' do
          get '/donate'
    
          expect(last_response).to be_ok
        end
      end
    end
    
  end
end

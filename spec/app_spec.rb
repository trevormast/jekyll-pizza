require 'spec_helper'
require 'sinatra/auth/github/test/test_helper'
require 'json'

describe 'App' do
  include Warden::Test::Helpers

  after do
    Warden.test_reset!
  end

	describe "GET '/'" do
    it "loads homepage" do
      get '/'
      expect(last_response).to be_ok
    end
   end
	
	describe "GET '/new'" do
    it "loads new page" do
      login_as Sinatra::Auth::Github::Test::Helper::User.make
      
      stub_request(:get, "https://api.github.com/repos/test_user/test_user.github.io").
         with(:headers => {'Accept'=>'application/vnd.github.v3+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Octokit Ruby Gem 4.1.1'}).
         to_return(:status => 200, :body => "", :headers => {})
      get '/new'
      expect(last_response).to be_ok
      expect(last_response.body).to include('test_user.github.io')
    end
  end

 describe "GET '/create'" do
    it "redirects to /new page" do
      get '/create'
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to eq('http://example.org/new')
    end
  end

  describe "POST '/create'" do
		it "creates me a jekyll blog" do
  		login_as Sinatra::Auth::Github::Test::Helper::User.make

  		# Check if root repo
  		stub_request(:get, "https://api.github.com/repos/test_user/test_user.github.io").
         to_return(:status => 200, :body => "", :headers => {})

      # Check if repo at given path   
    	stub_request(:get, "https://api.github.com/repos/test_user/path").
     		to_return(:status => 404, :body => "{ message: 'Not Found',
				documentation_url: 'https://developer.github.com/v3'}", :headers => {})

     	# Create repo
     	create_repo_response = File.read('./spec/create_repo_response.json')
     	stub_request(:post, "https://api.github.com/user/repos").
         with(:body => "{\"auto_init\":true,\"name\":\"path\"}",
              :headers => {'Accept'=>'application/vnd.github.v3+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Octokit Ruby Gem 4.1.1'}).
         to_return(:status => 201, :body => create_repo_response, :headers => {"Content-Type"=> "application/json"})
         # Digest::SHA1.hexdigest(SecureRandom.uuid)

      # Sha latest commit
      sha_latest_commit_response = File.read('./spec/sha_latest_commit_response.json')
      stub_request(:get, "https://api.github.com/repos/test_user/path/git/refs/heads/master").
         with(:headers => {'Accept'=>'application/vnd.github.v3+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Octokit Ruby Gem 4.1.1'}).
         to_return(:status => 200, :body => sha_latest_commit_response, :headers => {"Content-Type"=> "application/json"}) 

	    params =  {"site"=>{"title"=>"", "description"=>"", "root_url"=>"user.github.io", "path"=>"path", "theme"=>"clean-jekyll"}}
  		
  		post 'create', params
  		# binding.pry
  		# expect(site_params).to include("title")

  		expect(WebMock).to have_requested(:get, "https://api.github.com/repos/test_user/test_user.github.io")
	  	expect(WebMock).to have_requested(:get, "https://api.github.com/repos/test_user/path")
	  	expect(WebMock).to have_requested(:get, "https://api.github.com/user/repos")

  		# expect(last_response).to be_ok
  		# expect(last_response.location).to include('Oops, that repository already exists')
  	end	
  	
  end
end

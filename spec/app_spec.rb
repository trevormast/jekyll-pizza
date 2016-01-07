require 'spec_helper'
require 'sinatra/auth/github/test/test_helper'

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
end

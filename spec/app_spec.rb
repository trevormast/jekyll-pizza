require 'spec_helper'

describe 'App' do
	
	describe "GET '/'" do
    it "loads homepage" do
      get '/'
      expect(last_response).to be_ok
    end
   end
	
	describe "GET '/new'" do
    it "loads new page" do
      get '/new'
      user = double('user')
  		allow(request(7).env['warden']).to receive(:authenticate!).and_return(user)
  		allow(controller).to receive(:current_user).and_return(user)
      # stub_request(:get, "www.github.com").to_return(Warden::GitHub::User.new)
      expect(last_response).to be_ok
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

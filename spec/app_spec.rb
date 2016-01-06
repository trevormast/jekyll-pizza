require 'spec_helper'

describe 'App' do
	it 'should get the homepage' do
		get '/'
		expect(last_response).to be_ok
	end
end

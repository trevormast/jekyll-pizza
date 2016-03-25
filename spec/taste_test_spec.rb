require 'spec_helper'
require 'githubstubs'
require File.expand_path '../../lib/taste_test.rb', __FILE__
require File.expand_path '../../lib/oven.rb', __FILE__
require 'app_spec_helper'
require 'pry'

class JekyllPizza::TasteTest
  attr_reader :repo, :api, :order, :site_info
  attr_accessor :build_status
end

describe 'Taste Test' do
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

    @site_info = @oven.run(order: @order, dir: @dir)

    @taste = JekyllPizza::TasteTest.new
  end

  it 'is passed site info' do
    @taste.run(user: @user, site_info: @site_info)
    expect(@taste.site_info).to include(:repo)
  end

  it 'checks build status' do
    @taste.run(user: @user, site_info: @site_info)
    
    expect(a_request(:get, 'https://api.github.com/repos/test_user/path/pages')).to have_been_made.times(3)
  end

  it 'reports build status' do
    expect { @taste.run(user: @user, site_info: @site_info) }.to change { @taste.build_status }.from(nil).to('built')
  end
end

require 'spec_helper'
require 'githubstubs'
require 'app_spec_helper'

require File.expand_path '../../app.rb', __FILE__
require File.expand_path '../../workers/commit_worker.rb', __FILE__

describe 'Worker' do 
  before do
    class JekyllPizza::App
      def create_test_blog(_token, params)
        @job_id = CommitWorker.perform_async(params)
      end
    end

    @params =  { 'site' => { 'title' => 'test title', 'description' => 'test desc', 
                             'root_url' => 'test_user.github.io', 
                             'path' => 'deliverytest', 'theme' => 'clean-jekyll' } }
    def app
      JekyllPizza::App.allocate
    end
  end
  it 'returns a job id' do
    expect(app.create_test_blog('token', @params)).to match((/\A\S*\Z/))
  end
end

require 'spec_helper'

module GitHubStubs
  def self.valid_stubs
    # Check if root repo
    WebMock.stub_request(:get, 'https://api.github.com/repos/test_user/test_user.github.io').
      to_return(status: 200, body: '', headers: {})

    # Check if repo at given path   
    WebMock.stub_request(:get, 'https://api.github.com/repos/test_user/path').
      to_return(status: 404, body: "{ message: 'Not Found',
      documentation_url: 'https://developer.github.com/v3'}", headers: {})

    # Create repo
    create_repo_response = File.read('./spec/json/create_repo_response.json')
    WebMock.stub_request(:post, 'https://api.github.com/user/repos').
      to_return(status: 201, body: create_repo_response, headers: { 'Content-Type' => 'application/json' })
    # Digest::SHA1.hexdigest(SecureRandom.uuid)

    # Sha latest commit
    sha_latest_commit_response = File.read('./spec/json/sha_latest_commit_response.json')
    WebMock.stub_request(:get, 'https://api.github.com/repos/test_user/path/git/refs/heads/master').
      to_return(status: 200, body: sha_latest_commit_response, headers: { 'Content-Type' => 'application/json' }) 

    # Sha latest commit
    sha_latest_commit_response2 = File.read('./spec/json/sha_latest_commit_response2.json')
    WebMock.stub_request(:post, 'https://api.github.com/repos/test_user/path/git/refs').
      to_return(status: 201, body: sha_latest_commit_response2, headers: { 'Content-Type' => 'application/json' })

    # Sha base tree   
    sha_base_tree = File.read('./spec/json/sha_base_tree.json')
    WebMock.stub_request(:get, 'https://api.github.com/repos/test_user/path/commits/c0879ec586f927218eb41e5e51578afc0e71cd10').
      to_return(status: 200, body: sha_base_tree, headers: { 'Content-Type' => 'application/json' })

    # Sha latest commit update
    sha_latest_commit_update_response = File.read('./spec/json/sha_latest_commit_update.json')
    WebMock.stub_request(:get, 'https://api.github.com/repos/test_user/path/git/refs/heads/gh-pages').
      to_return(status: 200, body: sha_latest_commit_update_response, headers: { 'Content-Type' => 'application/json' })
   
    # Create blob
    create_blob = File.read('./spec/json/create_blob.json')
    WebMock.stub_request(:post, 'https://api.github.com/repos/test_user/path/git/blobs').
      to_return(status: 201, body: create_blob, headers: { 'Content-Type' => 'application/json' })

    # Create tree
    create_tree = File.read('./spec/json/create_tree.json')
    WebMock.stub_request(:post, 'https://api.github.com/repos/test_user/path/git/trees').
      to_return(status: 201, body: create_tree, headers: { 'Content-Type' => 'application/json' })

    # Create Commit
    create_commit = File.read('./spec/json/create_commit.json')
    WebMock.stub_request(:post, 'https://api.github.com/repos/test_user/path/git/commits').
      to_return(status: 201, body: create_commit, headers: { 'Content-Type' => 'application/json' })

    # Update ref
    update_ref = File.read('./spec/json/update_ref.json')
    WebMock.stub_request(:patch, 'https://api.github.com/repos/test_user/path/git/refs/heads/gh-pages').
      to_return(status: 200, body: update_ref, headers: { 'Content-Type' => 'application/json' })

    # TODO 
    WebMock.stub_request(:patch, 'https://api.github.com/repos/test_user/path').
      to_return(status: 200, body: '', headers: {})

    # check build
    building_status = File.read('./spec/json/building_status.json')
    built_status = File.read('./spec/json/built_status.json')
    errored_status = File.read('./spec/json/errored_status.json')
    WebMock.stub_request(:get, 'https://api.github.com/repos/test_user/path/pages').
      to_return(status: 200, body: building_status, headers: { 'Content-Type' => 'application/json' }).then.
      to_return(status: 200, body: errored_status, headers: { 'Content-Type' => 'application/json' }).then.
      to_return(status: 200, body: built_status, headers: { 'Content-Type' => 'application/json' })

    create_contents = File.read('./spec/json/create_contents.json')
    WebMock.stub_request(:get, 'https://api.github.com/repos/test_user/path/contents/README.md').
      to_return(status: 201, body: create_contents, headers: { 'Content-Type' => 'application/json' })

    WebMock.stub_request(:put, 'https://api.github.com/repos/test_user/path/contents/README.md').
      with(body: "{\"branch\":\"gh-pages\",\"sha\":\"\",\"content\":\"I1RoYW5rIHlvdSBmb3IgdXNpbmcgSmVreWxsLlBpenphIQ==\",\"message\":\"New build\"}",
           headers: { 'Accept' => 'application/vnd.github.v3+json', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Octokit Ruby Gem 4.1.1' }).
      to_return(status: 200, body: '', headers: {})

    # check build again
    
    # WebMock.stub_request(:get, 'https://api.github.com/repos/test_user/path/pages').
    # to_return(status: 200, body: built_status, headers: { 'Content-Type' => 'application/json' })
    # WebMock.stub_request(:get, "https://api.github.com/repos/test_user/path/pages").
    # with(:headers => {'Accept'=>'application/vnd.github.v3+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Octokit Ruby Gem 4.1.1'}).
         
  end
end

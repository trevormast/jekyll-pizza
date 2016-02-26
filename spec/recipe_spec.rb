require 'rspec'
require 'sinatra/auth/github/test/test_helper'
require 'pry'

require File.expand_path '../../lib/recipe.rb', __FILE__

class JekyllPizza::Recipe
  attr_reader :theme, :theme_path
end

describe 'Recipe' do
  before(:each) do
    @safe_params = { 'title' => 'test title', 'description' => 'test desc', 
                     'baseurl' => '/deliverytest',
                     'url' => 'test_user.github.io',
                     'github_username' => 'test_user',
                     'theme' => 'clean-jekyll' }
    # @theme = 'clean-jekyll'

    @recipe = JekyllPizza::Recipe.new
  end

  it 'should read' do
    expect(@recipe).to receive(:read)
    @recipe.read(@safe_params)
  end
  context 'when reading' do
    before(:each) do
      @recipe.read(@safe_params)
    end
    
    it 'should return correct theme path' do
      expect(@recipe.theme_path).to eq('./lib/themes/clean-jekyll')
    end

    it 'should update config.yml' do
      expect(@recipe).to respond_to(:update_config)
    end

    it 'should write user data to config' do
      expect(@recipe).to respond_to(:write_config)
    end

    # it 'should return correct parameters' do
    #   expect(@recipe.safe_params).to include('title' => 'test title')
    #   expect(@recipe.safe_params).to include('description' => 'test desc')
    #   expect(@recipe.safe_params).to include('baseurl' => '/deliverytest')
    #   expect(@recipe.safe_params).to include('url' => 'test_user.github.io')
    #   expect(@recipe.safe_params).to include('github_username' => 'test_user')
    # end
  end

  
end

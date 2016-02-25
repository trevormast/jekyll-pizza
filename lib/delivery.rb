require './lib/recipe'
require './lib/oven'

module JekyllPizza 
  class Delivery 
    attr_reader :safe_params, :user

    def initialize(user, safe_params)
      @user = user
      @safe_params = safe_params
    end

    def run
      @dir = Recipe.new(@safe_params).read
      @repo = Oven.new(@user, @dir, @safe_params).bake
    end
  end
end

require './lib/recipe'
require './lib/oven'

module JekyllPizza 
  class Delivery 
    attr_reader :safe_params, :user

    def initialize(user, safe_params, opts = {})
      @user = user
      @safe_params = safe_params
      @opts = opts
      
      @opts[:safe_params] = @safe_params
    end

    def run
      @dir = Recipe.new(@safe_params).read
      @site_info = Oven.new(@user, @dir, @opts).bake
    end
  end
end

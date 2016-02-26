require './lib/recipe'
require './lib/oven'

module JekyllPizza 
  class Delivery 
    def initialize(user, safe_params, opts = {}, recipe = Recipe.new, oven = Oven.new)
      @user = user
      @safe_params = safe_params
      @opts = opts
      @recipe = recipe
      @oven = oven

      # TODO: validate safe_params
      
      @opts[:safe_params] = @safe_params
    end

    def run
      @dir = @recipe.read(@safe_params)
      @site_info = @oven.bake(@user, @dir, @opts)
    end
  end
end

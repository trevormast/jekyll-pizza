module JekyllPizza
  class Delivery
    def initialize(order, directory, committer)
      @order = order
      @dir = directory
      @committer = committer
      @safe_params = @order.site_params
      @user = @order.user
    end

    def run
      @site_info = @committer.run(@order, @dir)
    end
  end
end

module JekyllPizza
  class Delivery
    def initialize(order, directory, committer, page_checker)
      @order = order
      @dir = directory
      @committer = committer
      @page_checker = page_checker
      @safe_params = @order.site_params
      @user = @order.user
    end

    def run
      @site_info = @committer.run(@order, @dir)
      @page_checker.run(@user, @site_info)
      @site_info
    end
  end
end

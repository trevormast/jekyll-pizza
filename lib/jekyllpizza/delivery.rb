module JekyllPizza
  class Delivery
    def initialize(args)
      @order = args[:order]
      @dir = args[:directory]
      @repo = args[:repo]
      @build_status = args[:build_status]
      @safe_params = @order.site_params
      @user = @order.user
    end

    def run
      @site_info = @repo.run(order: @order, dir: @dir)
      @build_status.run(user: @user, site_info: @site_info)
      @site_info
    end
  end
end

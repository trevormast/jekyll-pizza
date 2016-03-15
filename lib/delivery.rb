module JekyllPizza
  class Delivery
    attr_reader :build_status
    def initialize(args)
      @order = args[:order]
      @dir = args[:directory]
      @repo = args[:repo]
      @build_status = args[:build_status]
      @safe_params = @order.site_params
      @user = @order.user
    end

    def run
      Thread.new { create_blog }
    end

    private

    def create_blog
      @site_info = @repo.run(order: @order, dir: @dir)
      @build = @build_status.run(user: @user, site_info: @site_info)

      @site_info.merge!(build: @build)
    end
  end
end

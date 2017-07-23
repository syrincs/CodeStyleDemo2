module Concerns
  module SEO
    extend ActiveSupport::Concern

    NO_ROBOTS_CONTROLLERS = %w(search users sessions)

    included do
      helper_method :no_robots?
      helper_method :meta_robots_content
    end

    private

    def no_robots?
      NO_ROBOTS_CONTROLLERS.include? controller_name
    end

    def meta_robots_content
      'NOINDEX,NOFOLLOW'
    end
  end
end

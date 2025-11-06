module Admin
  class BaseController < ApplicationController
    layout 'admin'

    # TODO: Add authentication in future
    # before_action :authenticate_admin!

    private

    def authenticate_admin!
      # For now, no authentication
      # In production, you should add proper authentication
      # using devise, http basic auth, or similar
    end
  end
end

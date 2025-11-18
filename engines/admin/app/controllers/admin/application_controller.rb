module Admin
  class ApplicationController < ::ApplicationController
    before_action :require_admin
    layout "admin/application"

    private

    def require_admin
      unless current_user&.admin?
        flash[:alert] = "You must be an admin to access this page."
        redirect_to main_app.root_path
      end
    end
  end
end

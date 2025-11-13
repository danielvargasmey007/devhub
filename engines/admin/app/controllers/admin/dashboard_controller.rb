# Admin::DashboardController - Read-only admin dashboard
module Admin
  class DashboardController < ApplicationController
    def index
      @recent_projects = ::Project.limit(5)
      @task_counts = calculate_task_counts
    end

    private

    def calculate_task_counts
      ::Task.group(:status).count
    end
  end
end

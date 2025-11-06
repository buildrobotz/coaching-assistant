module Admin
  class DashboardController < Admin::BaseController
    def index
      @clients_count = Client.count
      @modules_count = CourseModule.count
      @lessons_count = Lesson.count
      @recent_clients = Client.order(created_at: :desc).limit(5)
    end
  end
end

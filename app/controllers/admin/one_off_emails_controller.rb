module Admin
  class OneOffEmailsController < Admin::BaseController
    def new
      @clients = Client.order(:name)
      @lessons = Lesson.includes(:course_module).order('course_modules.position, lessons.position')
    end

    def preview
      @client = find_client
      @html_content = render_content
      render layout: false
    end

    def create
      @client = find_client
      html_content = render_content
      subject = params[:subject].presence || "Message from Your Coach"

      sender = EmailSender.new
      if sender.send_one_off(
        client: @client,
        subject: subject,
        html_content: html_content
      )
        flash[:success] = "Email sent successfully to #{@client.email}!"
        redirect_to new_admin_one_off_email_path
      else
        flash.now[:error] = "Failed to send email. Please check the logs."
        @clients = Client.order(:name)
        @lessons = Lesson.includes(:course_module).order('course_modules.position, lessons.position')
        render :new
      end
    end

    private

    def find_client
      Client.find(params[:client_id])
    end

    def render_content
      if params[:use_lesson] == '1' && params[:lesson_id].present?
        # Use existing lesson
        lesson = Lesson.find(params[:lesson_id])
        # For now, just return placeholder - will load from GitHub in Phase 3
        "<h1>#{lesson.title}</h1><p>Lesson content will be loaded from GitHub in Phase 3.</p><p>Path: #{lesson.markdown_file_path}</p>"
      else
        # Use custom markdown
        markdown = params[:markdown_content]
        MarkdownRenderer.render(markdown)
      end
    end
  end
end

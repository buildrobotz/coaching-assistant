class LessonMailer < ApplicationMailer
  default from: -> { Rails.application.config.email.default_from }

  # Send a lesson email to a client
  # @param lesson_delivery [LessonDelivery] the lesson delivery record
  # @param html_content [String] the rendered HTML content of the lesson
  def lesson_email(lesson_delivery:, html_content:)
    @lesson_delivery = lesson_delivery
    @client = lesson_delivery.client
    @lesson = lesson_delivery.lesson
    @html_content = html_content
    @completion_token = lesson_delivery.completion_token

    # Generate completion URLs
    @complete_url = completion_url(token: @completion_token, next: false)
    @complete_next_url = completion_url(token: @completion_token, next: true)

    # Client streak info
    @current_streak = @client.current_streak
    @longest_streak = @client.longest_streak

    mail(
      to: @client.email,
      subject: @lesson.title
    )
  end

  # Send a one-off custom email
  # @param client [Client] the recipient
  # @param subject [String] email subject
  # @param html_content [String] the rendered HTML content
  def one_off_email(client:, subject:, html_content:)
    @client = client
    @html_content = html_content
    @current_streak = client.current_streak
    @longest_streak = client.longest_streak
    @is_one_off = true

    mail(
      to: client.email,
      subject: subject
    )
  end

  private

  def completion_url(token:, next:)
    "#{Rails.application.config.app_url}/complete/#{token}?next=#{next}"
  end
end

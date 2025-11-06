# Service for sending emails through the configured email provider
class EmailSender
  def initialize(provider: nil)
    @provider = provider || EmailProvider.current
  end

  # Send a lesson email
  # @param lesson_delivery [LessonDelivery] the lesson delivery record
  # @param html_content [String] rendered lesson HTML
  # @return [Boolean] true if sent successfully
  def send_lesson(lesson_delivery:, html_content:)
    mail = LessonMailer.lesson_email(
      lesson_delivery: lesson_delivery,
      html_content: html_content
    )

    send_mail(mail)
  end

  # Send a one-off email
  # @param client [Client] the recipient
  # @param subject [String] email subject
  # @param html_content [String] rendered HTML content
  # @return [Boolean] true if sent successfully
  def send_one_off(client:, subject:, html_content:)
    mail = LessonMailer.one_off_email(
      client: client,
      subject: subject,
      html_content: html_content
    )

    send_mail(mail)
  end

  # Test the email provider connection
  # @return [Boolean] true if connection is valid
  def test_connection
    @provider.test_connection
  end

  private

  def send_mail(mail)
    # Render the email HTML
    html_body = mail.body.to_s

    # Extract recipient and subject
    to = mail.to.first
    subject = mail.subject

    # Send via provider
    @provider.send_email(
      to: to,
      subject: subject,
      html_body: html_body
    )
  rescue StandardError => e
    Rails.logger.error("Failed to send email: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    false
  end
end

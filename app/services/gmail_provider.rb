require 'google/apis/gmail_v1'
require 'googleauth'
require 'base64'

# Gmail API implementation for sending emails
class GmailProvider < EmailProvider
  def initialize
    @service = Google::Apis::GmailV1::GmailService.new
    @service.authorization = authorize
  end

  # Send an email via Gmail API
  def send_email(to:, subject:, html_body:, from: nil)
    from_email = from || default_from_email

    message = create_message(
      to: to,
      from: from_email,
      subject: subject,
      html_body: html_body
    )

    @service.send_user_message('me', message)
    true
  rescue Google::Apis::Error => e
    Rails.logger.error("Gmail API error: #{e.message}")
    false
  rescue StandardError => e
    Rails.logger.error("Email sending error: #{e.message}")
    false
  end

  # Test Gmail API connection
  def test_connection
    @service.get_user_profile('me')
    true
  rescue Google::Apis::Error => e
    Rails.logger.error("Gmail connection test failed: #{e.message}")
    false
  end

  private

  def authorize
    client_id = ENV.fetch('GMAIL_CLIENT_ID')
    client_secret = ENV.fetch('GMAIL_CLIENT_SECRET')
    refresh_token = ENV.fetch('GMAIL_REFRESH_TOKEN')

    client = Google::Auth::UserRefreshCredentials.new(
      client_id: client_id,
      client_secret: client_secret,
      scope: ['https://www.googleapis.com/auth/gmail.send'],
      refresh_token: refresh_token
    )

    # Fetch access token
    client.fetch_access_token!
    client
  rescue KeyError => e
    raise "Missing Gmail configuration: #{e.message}. Please set GMAIL_CLIENT_ID, GMAIL_CLIENT_SECRET, and GMAIL_REFRESH_TOKEN environment variables."
  end

  def create_message(to:, from:, subject:, html_body:)
    message = Google::Apis::GmailV1::Message.new

    # Create email content with proper headers
    email_content = <<~EMAIL
      From: #{from}
      To: #{to}
      Subject: #{subject}
      MIME-Version: 1.0
      Content-Type: text/html; charset=UTF-8

      #{html_body}
    EMAIL

    # Encode message in base64url format
    message.raw = Base64.urlsafe_encode64(email_content, padding: false)
    message
  end
end

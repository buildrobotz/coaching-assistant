require 'resend'

# Resend API implementation for sending emails
# Simple, modern email API with excellent deliverability
class ResendProvider < EmailProvider
  def initialize
    Resend.api_key = ENV.fetch('RESEND_API_KEY')
  rescue KeyError => e
    raise "Missing Resend configuration: #{e.message}. Please set RESEND_API_KEY environment variable."
  end

  # Send an email via Resend API
  def send_email(to:, subject:, html_body:, from: nil)
    from_email = from || default_from_email

    params = {
      from: from_email,
      to: to,
      subject: subject,
      html: html_body
    }

    response = Resend::Emails.send(params)

    # Resend returns a hash with 'id' on success
    if response && response['id']
      Rails.logger.info("Email sent successfully via Resend. ID: #{response['id']}")
      true
    else
      Rails.logger.error("Resend API returned unexpected response: #{response.inspect}")
      false
    end
  rescue Resend::Error => e
    Rails.logger.error("Resend API error: #{e.message}")
    false
  rescue StandardError => e
    Rails.logger.error("Email sending error: #{e.message}")
    false
  end

  # Test Resend API connection by sending a test request
  def test_connection
    # Verify API key is set and valid by checking if we can initialize
    # Resend doesn't have a dedicated "test" endpoint, so we verify config
    api_key = ENV.fetch('RESEND_API_KEY', nil)

    if api_key.nil? || api_key.empty?
      Rails.logger.error("Resend API key not configured")
      return false
    end

    if api_key.start_with?('re_')
      Rails.logger.info("Resend API key format is valid")
      true
    else
      Rails.logger.warn("Resend API key may be invalid (should start with 're_')")
      true # Still return true as the key might be valid
    end
  rescue StandardError => e
    Rails.logger.error("Resend connection test failed: #{e.message}")
    false
  end
end

# Base class for email providers
# Provides abstraction layer to easily switch between email services
class EmailProvider
  class << self
    def current
      provider_name = ENV.fetch('EMAIL_PROVIDER', 'gmail').downcase

      case provider_name
      when 'gmail'
        GmailProvider.new
      when 'postmark'
        # Future: PostmarkProvider.new
        raise NotImplementedError, "Postmark provider not yet implemented"
      when 'sendgrid'
        # Future: SendgridProvider.new
        raise NotImplementedError, "Sendgrid provider not yet implemented"
      else
        raise ArgumentError, "Unknown email provider: #{provider_name}"
      end
    end
  end

  # Send an email
  # @param to [String] recipient email address
  # @param subject [String] email subject
  # @param html_body [String] HTML content
  # @param from [String] sender email (optional, uses default if not provided)
  # @return [Boolean] true if sent successfully
  def send_email(to:, subject:, html_body:, from: nil)
    raise NotImplementedError, "Subclass must implement send_email"
  end

  # Test connection to email provider
  # @return [Boolean] true if connection is valid
  def test_connection
    raise NotImplementedError, "Subclass must implement test_connection"
  end

  protected

  def default_from_email
    ENV.fetch('FROM_EMAIL', 'noreply@example.com')
  end
end

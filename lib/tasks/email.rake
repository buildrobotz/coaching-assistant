namespace :email do
  desc "Test email provider connection"
  task test_connection: :environment do
    puts "Testing email provider connection..."
    puts "Provider: #{ENV.fetch('EMAIL_PROVIDER', 'gmail')}"
    puts

    begin
      sender = EmailSender.new
      if sender.test_connection
        puts "✓ Connection successful!"
        puts "Email provider is configured correctly."
      else
        puts "✗ Connection failed!"
        puts "Please check your email provider credentials."
      end
    rescue StandardError => e
      puts "✗ Error: #{e.message}"
      puts
      puts "Make sure you have set the required environment variables:"
      puts "  - EMAIL_PROVIDER (default: gmail)"
      puts "  - GMAIL_CLIENT_ID"
      puts "  - GMAIL_CLIENT_SECRET"
      puts "  - GMAIL_REFRESH_TOKEN"
      puts
      puts "Run: ruby lib/scripts/gmail_oauth_setup.rb to get your tokens"
    end
  end

  desc "Send a test email"
  task :send_test, [:to_email] => :environment do |t, args|
    if args.to_email.blank?
      puts "Usage: rails email:send_test[your@email.com]"
      exit 1
    end

    puts "Sending test email to #{args.to_email}..."

    # Create a temporary client
    client = Client.new(
      name: "Test User",
      email: args.to_email,
      current_streak: 5,
      longest_streak: 10
    )

    html_content = <<~HTML
      <h1>Test Email</h1>
      <p>This is a test email from your Coaching Assistant application.</p>
      <p>If you're seeing this, your email configuration is working correctly! 🎉</p>

      <h2>Configuration Details</h2>
      <ul>
        <li>Email Provider: #{ENV.fetch('EMAIL_PROVIDER', 'gmail')}</li>
        <li>From Email: #{Rails.application.config.email.default_from}</li>
        <li>Timestamp: #{Time.current}</li>
      </ul>
    HTML

    sender = EmailSender.new
    if sender.send_one_off(
      client: client,
      subject: "Test Email - Coaching Assistant",
      html_content: html_content
    )
      puts "✓ Test email sent successfully!"
    else
      puts "✗ Failed to send test email. Check the logs for details."
    end
  end
end

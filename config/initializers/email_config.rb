# Email configuration
Rails.application.config.email = ActiveSupport::OrderedOptions.new

# Default from email
Rails.application.config.email.default_from = ENV.fetch('FROM_EMAIL', 'lessons@coaching-assistant.com')

# Email provider (gmail, postmark, sendgrid, etc.)
Rails.application.config.email.provider = ENV.fetch('EMAIL_PROVIDER', 'gmail')

# Streak mode (pause or reset)
Rails.application.config.streak_mode = ENV.fetch('STREAK_MODE', 'pause')

# Application URL (for generating completion links)
Rails.application.config.app_url = ENV.fetch('APP_URL', 'http://localhost:3000')

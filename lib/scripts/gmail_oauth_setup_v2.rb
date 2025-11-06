#!/usr/bin/env ruby
# Helper script to obtain Gmail OAuth refresh token
# Usage: ruby lib/scripts/gmail_oauth_setup_v2.rb

require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/gmail_v1'
require 'fileutils'

puts "=" * 60
puts "Gmail OAuth Setup for Coaching Assistant"
puts "=" * 60
puts

# Check for existing tokens
if File.exist?('tokens.yaml')
  puts "⚠️  Found existing tokens from previous setup"
  print "Do you want to create NEW credentials? (yes/no): "
  answer = gets.chomp.downcase

  if answer == 'yes' || answer == 'y'
    puts "Deleting old tokens..."
    File.delete('tokens.yaml')
    puts "✓ Old tokens deleted. Starting fresh setup."
    puts
  else
    puts "Keeping existing tokens. Exiting..."
    exit 0
  end
end

# Get credentials from user
puts "Please enter your Gmail API credentials from Google Cloud Console:"
puts
print "Enter your Gmail Client ID: "
client_id = gets.chomp

if client_id.strip.empty?
  puts "❌ Error: Client ID cannot be empty!"
  exit 1
end

print "Enter your Gmail Client Secret: "
client_secret = gets.chomp

if client_secret.strip.empty?
  puts "❌ Error: Client Secret cannot be empty!"
  exit 1
end

puts
puts "Using credentials for Gmail account setup..."
puts

SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_SEND
REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'

begin
  # Create client
  client = Google::Auth::ClientId.new(client_id, client_secret)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: 'tokens.yaml')
  authorizer = Google::Auth::UserAuthorizer.new(client, SCOPE, token_store)

  user_id = 'default'

  # Always get new authorization
  url = authorizer.get_authorization_url(base_url: REDIRECT_URI)

  puts "STEP 1: Open this URL in your browser:"
  puts "-" * 60
  puts url
  puts "-" * 60
  puts
  puts "STEP 2: Sign in with the Gmail account you want to use"
  puts "        (e.g., buildrobotz@gmail.com)"
  puts
  puts "STEP 3: Authorize the application and copy the authorization code"
  puts
  print "Enter the authorization code: "
  code = gets.chomp

  if code.strip.empty?
    puts "❌ Error: Authorization code cannot be empty!"
    exit 1
  end

  puts
  puts "Processing authorization code..."

  credentials = authorizer.get_and_store_credentials_from_code(
    user_id: user_id,
    code: code,
    base_url: REDIRECT_URI
  )

  puts
  puts "=" * 60
  puts "✓ SUCCESS! Gmail API is now configured"
  puts "=" * 60
  puts
  puts "Add these lines to your .env file:"
  puts
  puts "FROM_EMAIL=buildrobotz@gmail.com  # ← Use the email you just authorized"
  puts "GMAIL_CLIENT_ID=#{client_id}"
  puts "GMAIL_CLIENT_SECRET=#{client_secret}"
  puts "GMAIL_REFRESH_TOKEN=#{credentials.refresh_token}"
  puts
  puts "=" * 60
  puts "Setup complete!"
  puts "=" * 60
  puts
  puts "Next steps:"
  puts "1. Copy the lines above to your .env file"
  puts "2. Make sure FROM_EMAIL matches the Gmail account you authorized"
  puts "3. Run: bin/rails email:test_connection"
  puts

rescue Google::Apis::ClientError => e
  puts
  puts "❌ Error from Google API:"
  puts e.message
  puts
  puts "Common issues:"
  puts "- Make sure you copied the FULL authorization code"
  puts "- Check that your Client ID and Secret are correct"
  puts "- Verify Gmail API is enabled in Google Cloud Console"
  puts

rescue StandardError => e
  puts
  puts "❌ Unexpected error:"
  puts e.message
  puts
  puts "Please check:"
  puts "1. Your internet connection"
  puts "2. That you have the required gems installed (bundle install)"
  puts "3. Your Client ID and Secret are correct"
  puts
end

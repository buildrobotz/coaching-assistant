#!/usr/bin/env ruby
# Helper script to obtain Gmail OAuth refresh token
# Usage: ruby lib/scripts/gmail_oauth_setup.rb

require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/gmail_v1'

puts "=" * 60
puts "Gmail OAuth Setup for Coaching Assistant"
puts "=" * 60
puts

# Get credentials from user
print "Enter your Gmail Client ID: "
client_id = gets.chomp

print "Enter your Gmail Client Secret: "
client_secret = gets.chomp

puts

SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_SEND
REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'

# Create client
client = Google::Auth::ClientId.new(client_id, client_secret)
token_store = Google::Auth::Stores::FileTokenStore.new(file: 'tokens.yaml')
authorizer = Google::Auth::UserAuthorizer.new(client, SCOPE, token_store)

user_id = 'default'
credentials = authorizer.get_credentials(user_id)

if credentials.nil?
  url = authorizer.get_authorization_url(base_url: REDIRECT_URI)

  puts "STEP 1: Open this URL in your browser:"
  puts "-" * 60
  puts url
  puts "-" * 60
  puts
  puts "STEP 2: Authorize the application and copy the authorization code"
  puts
  print "Enter the authorization code: "
  code = gets.chomp

  credentials = authorizer.get_and_store_credentials_from_code(
    user_id: user_id,
    code: code,
    base_url: REDIRECT_URI
  )
end

puts
puts "=" * 60
puts "SUCCESS! Add these to your .env file:"
puts "=" * 60
puts
puts "GMAIL_CLIENT_ID=#{client_id}"
puts "GMAIL_CLIENT_SECRET=#{client_secret}"
puts "GMAIL_REFRESH_TOKEN=#{credentials.refresh_token}"
puts
puts "=" * 60
puts "Setup complete!"
puts "=" * 60

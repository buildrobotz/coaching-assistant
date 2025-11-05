# Coaching Assistant

A Ruby on Rails application for delivering daily coaching lessons to clients via email. Supports self-paced learning with customizable module sequences per client.

## Features

- **Custom Module Sequences**: Assign unique lesson sequences to each client based on their needs
- **Self-Paced Learning**: Clients control their lesson flow
- **Daily Lesson Delivery**: Automated email delivery based on client timezone
- **Streak Tracking**: Maintains current and longest streak counts
- **Lesson Limits**: Maximum 3 lessons per day to prevent overwhelm
- **One-Off Emails**: Send custom emails based on markdown files or ad-hoc content
- **GitHub Integration**: Lessons stored as markdown files in GitHub repository
- **Syntax Highlighting**: Code blocks in lessons are beautifully highlighted
- **Email Provider Abstraction**: Easy to switch between Gmail API and other providers

## Tech Stack

- **Framework**: Ruby on Rails 7.1
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq + Redis
- **Email**: Gmail API (abstracted for easy switching)
- **Markdown**: Redcarpet + Rouge
- **Styling**: Tailwind CSS
- **Hosting**: Render (recommended)

## Prerequisites

- Ruby 3.3.6
- PostgreSQL 12+
- Redis (for Sidekiq)
- Gmail API credentials (for email sending)
- GitHub Personal Access Token (for lesson content)

## Local Development Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd coaching-assistant
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Configure Environment Variables

Create a `.env` file in the root directory:

```bash
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=your_postgres_user
DB_PASSWORD=your_postgres_password

# Email Provider
EMAIL_PROVIDER=gmail  # or 'postmark', 'sendgrid', etc.

# Gmail API Configuration
GMAIL_CLIENT_ID=your_gmail_client_id
GMAIL_CLIENT_SECRET=your_gmail_client_secret
GMAIL_REFRESH_TOKEN=your_gmail_refresh_token

# GitHub Configuration
GITHUB_TOKEN=your_github_personal_access_token
GITHUB_REPO=your_username/your_lessons_repo
GITHUB_BRANCH=main

# Redis Configuration (for Sidekiq)
REDIS_URL=redis://localhost:6379/0

# Streak Configuration
STREAK_MODE=pause  # 'pause' or 'reset'
```

### 4. Setup PostgreSQL

#### On macOS:
```bash
brew install postgresql@14
brew services start postgresql@14
createdb coaching_assistant_development
```

#### On Ubuntu/Debian:
```bash
sudo apt-get install postgresql postgresql-contrib
sudo service postgresql start
sudo -u postgres createuser -s $USER
createdb coaching_assistant_development
```

#### On Docker:
```bash
docker run -d \
  --name coaching-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:14

# Set DB_PASSWORD=postgres in .env
```

### 5. Setup Redis

#### On macOS:
```bash
brew install redis
brew services start redis
```

#### On Ubuntu/Debian:
```bash
sudo apt-get install redis-server
sudo service redis-server start
```

#### On Docker:
```bash
docker run -d \
  --name coaching-redis \
  -p 6379:6379 \
  redis:7
```

### 6. Create and Migrate Database

```bash
bin/rails db:create
bin/rails db:migrate
```

### 7. Run the Application

In one terminal:
```bash
bin/dev
```

Or run components separately:

```bash
# Terminal 1: Rails server
bin/rails server

# Terminal 2: Tailwind CSS
bin/rails tailwindcss:watch

# Terminal 3: Sidekiq
bundle exec sidekiq
```

Visit: http://localhost:3000

## Deploying to Render

### 1. Prerequisites

- Render account (https://render.com)
- GitHub repository with this code
- Gmail API credentials
- GitHub Personal Access Token

### 2. Create Services

#### A. Create PostgreSQL Database

1. Go to Render Dashboard
2. Click "New +" → "PostgreSQL"
3. Name: `coaching-assistant-db`
4. Database: `coaching_assistant`
5. Click "Create Database"
6. Copy the "Internal Database URL"

#### B. Create Redis Instance

1. Click "New +" → "Redis"
2. Name: `coaching-assistant-redis`
3. Click "Create Redis"
4. Copy the "Internal Redis URL"

#### C. Create Web Service

1. Click "New +" → "Web Service"
2. Connect your GitHub repository
3. Configure:
   - **Name**: `coaching-assistant`
   - **Environment**: `Ruby`
   - **Build Command**: `bundle install && bin/rails assets:precompile && bin/rails db:migrate`
   - **Start Command**: `bin/rails server -b 0.0.0.0`
   - **Plan**: Free or Starter

4. Add Environment Variables:
```
DATABASE_URL=<paste PostgreSQL Internal URL>
REDIS_URL=<paste Redis Internal URL>
RAILS_MASTER_KEY=<from config/master.key>
RAILS_ENV=production
RACK_ENV=production
EMAIL_PROVIDER=gmail
GMAIL_CLIENT_ID=<your gmail client id>
GMAIL_CLIENT_SECRET=<your gmail client secret>
GMAIL_REFRESH_TOKEN=<your gmail refresh token>
GITHUB_TOKEN=<your github token>
GITHUB_REPO=<username/repo>
GITHUB_BRANCH=main
STREAK_MODE=pause
```

5. Click "Create Web Service"

#### D. Create Sidekiq Worker

1. Click "New +" → "Background Worker"
2. Connect same GitHub repository
3. Configure:
   - **Name**: `coaching-assistant-worker`
   - **Environment**: `Ruby`
   - **Build Command**: `bundle install`
   - **Start Command**: `bundle exec sidekiq`

4. Add same environment variables as web service

5. Click "Create Background Worker"

### 3. Deploy

Render will automatically deploy your application. Monitor the logs for any issues.

### 4. Run Initial Migration (if needed)

If migrations don't run automatically:

1. Go to Web Service → Shell
2. Run: `bin/rails db:migrate`

### 5. Access Your App

Your app will be available at: `https://coaching-assistant.onrender.com`

## Gmail API Setup

### 1. Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project: "Coaching Assistant"
3. Enable Gmail API:
   - Go to "APIs & Services" → "Library"
   - Search for "Gmail API"
   - Click "Enable"

### 2. Create OAuth Credentials

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth client ID"
3. Configure OAuth consent screen (if prompted)
4. Application type: "Desktop app"
5. Name: "Coaching Assistant OAuth"
6. Click "Create"
7. Download the JSON file

### 3. Get Refresh Token

Run this Ruby script locally (save as `gmail_oauth.rb`):

```ruby
require 'googleauth'
require 'googleauth/stores/file_token_store'

CLIENT_ID = 'your_client_id'
CLIENT_SECRET = 'your_client_secret'
SCOPE = 'https://www.googleapis.com/auth/gmail.send'
REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'

client_id = Google::Auth::ClientId.new(CLIENT_ID, CLIENT_SECRET)
token_store = Google::Auth::Stores::FileTokenStore.new(file: 'tokens.yaml')
authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)

user_id = 'default'
credentials = authorizer.get_credentials(user_id)

if credentials.nil?
  url = authorizer.get_authorization_url(base_url: REDIRECT_URI)
  puts "Open this URL in your browser:"
  puts url
  puts "\nEnter the authorization code:"
  code = gets.chomp
  credentials = authorizer.get_and_store_credentials_from_code(
    user_id: user_id, code: code, base_url: REDIRECT_URI
  )
end

puts "\n=== Add these to your .env file ==="
puts "GMAIL_REFRESH_TOKEN=#{credentials.refresh_token}"
puts "GMAIL_CLIENT_ID=#{CLIENT_ID}"
puts "GMAIL_CLIENT_SECRET=#{CLIENT_SECRET}"
```

Run it:
```bash
ruby lib/scripts/gmail_oauth_setup.rb
```

### 4. Test Email Configuration

After setting up Gmail credentials, test the connection:

```bash
# Test connection to Gmail API
bin/rails email:test_connection

# Send a test email to verify everything works
bin/rails email:send_test[your@email.com]
```

## Usage Guide

### Creating Modules & Lessons

1. Create a GitHub repository for your lessons
2. Organize with folder structure:
```
lessons/
├── module-1-foundations/
│   ├── 01-welcome.md
│   ├── 02-getting-started.md
│   └── images/
└── module-2-advanced/
    └── 01-advanced-techniques.md
```

3. In the admin panel (`/admin/course_modules`):
   - Create modules
   - Add lessons with paths like: `lessons/module-1-foundations/01-welcome.md`

### Enrolling Clients

1. Go to `/admin/clients` → "New Client"
2. Fill in details (name, email, timezone, preferred time)
3. Click "Enroll"
4. Select modules in desired order
5. First lesson will be scheduled automatically

### Sending One-Off Emails

1. Go to `/admin/one_off_emails`
2. Select client
3. Either pick an existing lesson or write custom markdown
4. Preview and send

## Markdown Lesson Format

```markdown
# Lesson Title

Introduction paragraph...

## Section Heading

Content with **bold** and *italic* text.

### Code Example

\`\`\`ruby
def greet(name)
  puts "Hello, #{name}!"
end
\`\`\`

### Images

![Alt text](./images/diagram.png)

### Videos

Embed YouTube:
[Watch this tutorial](https://www.youtube.com/watch?v=VIDEO_ID)
```

## Troubleshooting

### PostgreSQL Issues

```bash
# Check if running
pg_isready

# Start PostgreSQL
# macOS:
brew services start postgresql

# Linux:
sudo service postgresql start

# Docker:
docker start coaching-postgres
```

### Redis Issues

```bash
# Check if running
redis-cli ping
# Should return: PONG

# Start Redis
# macOS:
brew services start redis

# Linux:
sudo service redis-server start

# Docker:
docker start coaching-redis
```

### Migration Issues

```bash
# Drop and recreate
bin/rails db:drop db:create db:migrate

# Check status
bin/rails db:migrate:status
```

### Render Deployment Issues

1. Check build logs in Render dashboard
2. Verify all environment variables are set
3. Ensure `RAILS_MASTER_KEY` is correct
4. Check PostgreSQL connection string

## Architecture

### Models

- **Client**: Stores client info, timezone, streaks
- **CourseModule**: Lesson modules
- **Lesson**: Individual lessons
- **ClientEnrollment**: Links clients to module sequences
- **EnrollmentModule**: Defines module order
- **LessonDelivery**: Tracks sent/completed lessons
- **DailyCompletion**: Enforces 3-lesson-per-day limit

### Services

- **EmailProvider**: ✅ Email abstraction layer for switching providers
- **GmailProvider**: ✅ Gmail API implementation
- **EmailSender**: ✅ Service for sending emails via providers
- **LessonMailer**: ✅ Mailer for lesson and one-off emails
- **LessonRenderer**: Markdown → HTML converter (Phase 3)
- **StreakCalculator**: Manages streaks (Phase 5)
- **GithubLessonLoader**: Fetches lessons from GitHub (Phase 3)

## Development Roadmap

- [x] Phase 1: Rails setup + Database + Render instructions
- [x] Phase 4: Email provider abstraction + Gmail API
- [ ] Phase 7: One-off email functionality (MVP!)
- [ ] Phase 3: GitHub integration + Markdown rendering
- [ ] Phase 5: Lesson delivery system + Scheduling
- [ ] Phase 2: Admin interface (CRUD)
- [ ] Phase 8: Preview functionality
- [ ] Phase 9: Final deployment polish

## License

MIT

## Support

Create an issue on GitHub for questions or problems.

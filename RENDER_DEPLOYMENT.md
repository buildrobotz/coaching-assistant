# Deploying to Render (Free Tier)

This guide walks you through deploying the Coaching Assistant app using **free tiers** from multiple services.

## Cost Summary

| Service | Provider | Free Tier | Monthly Cost |
|---------|----------|-----------|--------------|
| Web App | Render | 750 hrs/month | **$0** |
| Database | Supabase | 500MB PostgreSQL | **$0** |
| Email | Resend | 3,000 emails/month | **$0** |
| Redis | Upstash | 10K commands/day | **$0** |
| **Total** | | | **$0/month** |

---

## Prerequisites

- GitHub account with your code pushed
- Free accounts on: Render, Supabase, Resend, Upstash

---

## Step 1: Set Up Supabase (Free PostgreSQL Database)

### 1.1 Create Account
1. Go to [supabase.com](https://supabase.com)
2. Sign up with GitHub (recommended)
3. Create a new organization if prompted

### 1.2 Create Project
1. Click **"New Project"**
2. Fill in:
   - **Name**: `coaching-assistant`
   - **Database Password**: Generate a strong password (save this!)
   - **Region**: Choose closest to your users
3. Click **"Create new project"**
4. Wait 2-3 minutes for provisioning

### 1.3 Get Connection String
1. Go to **Settings** → **Database**
2. Scroll to **"Connection string"** section
3. Select **"URI"** tab
4. Copy the connection string

Your `DATABASE_URL` will look like:
```
postgresql://postgres.[project-ref]:[YOUR-PASSWORD]@aws-0-[region].pooler.supabase.com:6543/postgres
```

**Important**: Replace `[YOUR-PASSWORD]` with your actual database password.

---

## Step 2: Set Up Resend (Email Provider)

### 2.1 Create Account
1. Go to [resend.com](https://resend.com)
2. Sign up with GitHub or email
3. Verify your email

### 2.2 Get API Key
1. Go to **API Keys** in the sidebar
2. Click **"Create API Key"**
3. Name it: `coaching-assistant-production`
4. Select permissions: **Full access** (or Sending access)
5. Click **"Add"**
6. **Copy the API key immediately** (starts with `re_`)

Your `RESEND_API_KEY` will look like:
```
re_123abc456def...
```

### 2.3 Configure Sender (Optional for Testing)

**For testing**: Use `onboarding@resend.dev` as your FROM_EMAIL

**For production**: Add and verify your domain:
1. Go to **Domains** → **Add Domain**
2. Add DNS records as instructed
3. Wait for verification (usually minutes)
4. Use `your-email@your-domain.com` as FROM_EMAIL

---

## Step 3: Set Up Upstash Redis (For Sidekiq)

### 3.1 Create Account
1. Go to [upstash.com](https://upstash.com)
2. Sign up with GitHub

### 3.2 Create Redis Database
1. Click **"Create Database"**
2. Fill in:
   - **Name**: `coaching-assistant-redis`
   - **Type**: Regional
   - **Region**: Same as your Render region
3. Click **"Create"**

### 3.3 Get Connection URL
1. In database details, find **"REST API"** section
2. Copy the **UPSTASH_REDIS_REST_URL**

Or use the standard Redis URL format:
```
redis://default:[password]@[endpoint]:6379
```

---

## Step 4: Deploy to Render

### 4.1 Create Render Account
1. Go to [render.com](https://render.com)
2. Sign up with GitHub (recommended)

### 4.2 Create Web Service
1. Click **"New +"** → **"Web Service"**
2. Connect your GitHub repository
3. Select your `coaching-assistant` repo

### 4.3 Configure Service

**Basic Settings:**
- **Name**: `coaching-assistant`
- **Region**: Oregon (or closest to you)
- **Branch**: `main` (or your production branch)
- **Runtime**: `Ruby`
- **Instance Type**: **Free**

**Build Settings:**
```bash
Build Command: bundle install && bin/rails assets:precompile && bin/rails db:migrate
```

**Start Command:**
```bash
bin/rails server -b 0.0.0.0
```

### 4.4 Add Environment Variables

Click **"Advanced"** → **"Add Environment Variable"** and add:

```bash
# Database (from Supabase)
DATABASE_URL=postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres

# Email (from Resend)
EMAIL_PROVIDER=resend
RESEND_API_KEY=re_your_api_key_here
FROM_EMAIL=onboarding@resend.dev

# Redis (from Upstash)
REDIS_URL=redis://default:[password]@[endpoint]:6379

# Rails Configuration
RAILS_ENV=production
RACK_ENV=production
SECRET_KEY_BASE=<generate-with-rails-secret>
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Application
APP_URL=https://coaching-assistant.onrender.com

# GitHub (for lesson content)
GITHUB_TOKEN=your_github_token
GITHUB_REPO=your_username/your_lessons_repo
GITHUB_BRANCH=main

# Streak Configuration
STREAK_MODE=pause
```

**Generate SECRET_KEY_BASE:**
```bash
# Run locally:
bin/rails secret
```

### 4.5 Deploy
1. Click **"Create Web Service"**
2. Wait for build and deploy (5-10 minutes first time)
3. Your app will be live at: `https://coaching-assistant.onrender.com`

---

## Step 5: Set Up Background Worker (Optional)

For background jobs (Sidekiq), you'll need a second Render service:

### 5.1 Create Background Worker
1. Click **"New +"** → **"Background Worker"**
2. Connect same repository
3. Use **Free** instance

**Start Command:**
```bash
bundle exec sidekiq
```

Add the same environment variables as your web service.

**Note**: Free tier workers also sleep after 15 min of inactivity.

---

## Step 6: Verify Deployment

### 6.1 Check Web Service
1. Visit your Render URL
2. Should see the app homepage

### 6.2 Test Email Connection
```bash
# In Render shell or locally with production env
bin/rails email:test_connection
```

### 6.3 Send Test Email
```bash
bin/rails email:send_test[your-email@example.com]
```

---

## Important Limitations

### Render Free Tier
- ⚠️ **Auto-sleep after 15 min idle** - First request after sleep takes ~1 min
- 750 hours/month (enough for 24/7 operation)
- No custom domain SSL on free tier

### Supabase Free Tier
- 500MB database storage
- 2GB bandwidth/month
- 50MB file storage
- **No expiration** (unlike Render's 30-day PostgreSQL)

### Resend Free Tier
- 3,000 emails/month
- 100 emails/day
- Single sender domain

### Upstash Free Tier
- 10,000 commands/day
- 256MB storage
- Single database

---

## Keeping Your App Awake (Optional)

To prevent Render from sleeping your app, use a free uptime monitor:

### UptimeRobot (Free)
1. Go to [uptimerobot.com](https://uptimerobot.com)
2. Create account
3. Add monitor:
   - **Type**: HTTP(s)
   - **URL**: `https://your-app.onrender.com`
   - **Interval**: 5 minutes

This pings your app every 5 minutes, preventing sleep.

---

## Troubleshooting

### Build Fails
```bash
# Check Ruby version matches
cat .ruby-version  # Should be 3.3.6
```

### Database Connection Issues
```bash
# Verify DATABASE_URL format
# Should be: postgresql://user:pass@host:port/database
```

### Email Not Sending
```bash
# Check Resend API key starts with 're_'
# Verify FROM_EMAIL is allowed sender
```

### Redis Connection Issues
```bash
# Check REDIS_URL format
# Upstash uses different format than local Redis
```

---

## Local Development with Same Services

You can test with production services locally:

```bash
# .env.local
DATABASE_URL=your_supabase_url
RESEND_API_KEY=your_resend_key
REDIS_URL=your_upstash_url
EMAIL_PROVIDER=resend
FROM_EMAIL=onboarding@resend.dev
```

**Warning**: This uses production database! Create a separate Supabase project for development if needed.

---

## Next Steps

1. **Custom Domain**: Add your own domain in Render settings
2. **Verify Email Domain**: Configure custom sender in Resend
3. **Monitor Usage**: Watch Supabase and Resend dashboards
4. **Upgrade When Ready**: Each service has affordable paid tiers

---

## Quick Reference

| Service | Dashboard URL |
|---------|--------------|
| Render | [dashboard.render.com](https://dashboard.render.com) |
| Supabase | [app.supabase.com](https://app.supabase.com) |
| Resend | [resend.com/emails](https://resend.com/emails) |
| Upstash | [console.upstash.com](https://console.upstash.com) |

---

## Support

- **Render Docs**: [render.com/docs](https://render.com/docs)
- **Supabase Docs**: [supabase.com/docs](https://supabase.com/docs)
- **Resend Docs**: [resend.com/docs](https://resend.com/docs)
- **Upstash Docs**: [upstash.com/docs](https://upstash.com/docs)

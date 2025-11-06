# Gmail API Setup Guide

Complete step-by-step instructions to configure Gmail API for sending emails from your Coaching Assistant application.

---

## Part 1: Create Google Cloud Project & Get Client ID/Secret

### Step 1: Go to Google Cloud Console

1. Open https://console.cloud.google.com/
2. Sign in with your Google account (the one you want to send emails from)

### Step 2: Create a New Project

1. Click the project dropdown at the top (says "Select a project")
2. Click **"NEW PROJECT"** in the top right
3. Enter project details:
   - **Project name**: `Coaching Assistant` (or any name you like)
   - **Organization**: Leave as default or select your org
4. Click **"CREATE"**
5. Wait a few seconds for the project to be created
6. Make sure your new project is selected in the dropdown

### Step 3: Enable Gmail API

1. In the left sidebar, go to **"APIs & Services"** → **"Library"**
   - Or use the search bar at the top and search for "Gmail API"
2. Search for **"Gmail API"**
3. Click on **"Gmail API"** in the results
4. Click the blue **"ENABLE"** button
5. Wait for it to enable (takes a few seconds)

### Step 4: Configure OAuth Consent Screen

1. Go to **"APIs & Services"** → **"OAuth consent screen"** (left sidebar)
2. Select **"External"** (unless you have a Google Workspace account, then you can choose Internal)
3. Click **"CREATE"**
4. Fill in the required fields:
   - **App name**: `Coaching Assistant`
   - **User support email**: Your email address
   - **Developer contact information**: Your email address
5. Leave everything else as default
6. Click **"SAVE AND CONTINUE"**
7. On the "Scopes" page, click **"SAVE AND CONTINUE"** (don't add any scopes manually)
8. On the "Test users" page:
   - Click **"+ ADD USERS"**
   - Enter YOUR email address (the one you'll send emails from)
   - Click **"ADD"**
9. Click **"SAVE AND CONTINUE"**
10. Review and click **"BACK TO DASHBOARD"**

### Step 5: Create OAuth 2.0 Credentials

1. Go to **"APIs & Services"** → **"Credentials"** (left sidebar)
2. Click **"+ CREATE CREDENTIALS"** at the top
3. Select **"OAuth client ID"**
4. Choose **Application type**: **"Desktop app"**
5. **Name**: `Coaching Assistant Desktop` (or any name)
6. Click **"CREATE"**
7. A dialog will appear with your credentials!

### Step 6: Download Your Credentials

1. In the popup that appears, you'll see:
   - **Your Client ID**: Something like `123456789-abc123def456.apps.googleusercontent.com`
   - **Your Client Secret**: Something like `GOCSPX-abc123def456xyz789`
2. **Copy these somewhere safe!** You'll need them in a moment.
3. You can also click **"DOWNLOAD JSON"** to save them as a file
4. Click **"OK"** to close the dialog

> **Note:** You can always view these again by going to Credentials and clicking on your OAuth 2.0 Client ID

---

## Part 2: Get Your Refresh Token

Now that you have your Client ID and Client Secret, let's get the refresh token.

### Step 1: Add Credentials to Your Project

1. Open your terminal
2. Navigate to your coaching-assistant project:
```bash
cd /path/to/coaching-assistant
```

3. Make sure you have the required gems installed:
```bash
bundle install
```

### Step 2: Run the OAuth Setup Script

1. Run our OAuth setup script:
```bash
ruby lib/scripts/gmail_oauth_setup.rb
```

2. The script will prompt you:
```
============================================================
Gmail OAuth Setup for Coaching Assistant
============================================================

Enter your Gmail Client ID:
```

3. **Paste your Client ID** and press Enter

4. Then it will ask:
```
Enter your Gmail Client Secret:
```

5. **Paste your Client Secret** and press Enter

### Step 3: Authorize the Application

1. The script will output a URL that looks like:
```
STEP 1: Open this URL in your browser:
------------------------------------------------------------
https://accounts.google.com/o/oauth2/auth?client_id=...
------------------------------------------------------------
```

2. **Copy the entire URL** and paste it into your browser

3. You'll see a Google sign-in page:
   - Sign in with the same Google account
   - You might see a warning: "Google hasn't verified this app"
   - Click **"Advanced"** at the bottom left
   - Click **"Go to Coaching Assistant (unsafe)"**
   - Click **"Continue"**

4. Google will ask for permission:
   - You'll see: "Coaching Assistant wants to access your Google Account"
   - Check the box for **"Send email on your behalf"**
   - Click **"Continue"**

5. You'll see a page with an authorization code:
```
Please copy this code, switch to your application and paste it there:
4/0Adeu5BW...long code here...
```

6. **Copy the entire code**

### Step 4: Complete the Setup

1. Go back to your terminal where the script is waiting:
```
STEP 2: Authorize the application and copy the authorization code

Enter the authorization code:
```

2. **Paste the authorization code** and press Enter

3. The script will process and output:
```
============================================================
SUCCESS! Add these to your .env file:
============================================================

GMAIL_CLIENT_ID=your_client_id_here
GMAIL_CLIENT_SECRET=your_client_secret_here
GMAIL_REFRESH_TOKEN=1//0gABCDEF...long refresh token...

============================================================
Setup complete!
============================================================
```

4. **Copy all three lines!**

### Step 5: Add to Your .env File

1. Create or open your `.env` file in the project root:
```bash
cp .env.example .env
nano .env
```

2. Paste the three lines from the script output:
```bash
GMAIL_CLIENT_ID=your_actual_client_id
GMAIL_CLIENT_SECRET=your_actual_client_secret
GMAIL_REFRESH_TOKEN=your_actual_refresh_token
```

3. Also make sure you have these settings:
```bash
FROM_EMAIL=your-email@gmail.com
EMAIL_PROVIDER=gmail
APP_URL=http://localhost:3000
```

4. Save and exit (Ctrl+X, then Y, then Enter in nano)

---

## Part 3: Test Your Setup

### Test 1: Check Connection

```bash
bin/rails email:test_connection
```

You should see:
```
Testing email provider connection...
Provider: gmail

✓ Connection successful!
Email provider is configured correctly.
```

### Test 2: Send a Test Email

```bash
bin/rails email:send_test[your-email@gmail.com]
```

Replace `your-email@gmail.com` with your actual email. You should see:
```
Sending test email to your-email@gmail.com...
✓ Test email sent successfully!
```

Check your inbox - you should have received a beautiful test email!

---

## Troubleshooting

### "Access blocked: This app's request is invalid"

**Solution:** Make sure you added your email as a "Test user" in the OAuth consent screen (Part 1, Step 4, point 8).

### "Invalid grant" error

**Solution:** Your refresh token might have expired. Run the OAuth setup script again to get a new one.

### "Unauthorized client"

**Solution:** Make sure you:
1. Enabled the Gmail API
2. Created OAuth credentials for "Desktop app" (not "Web application")
3. Used the correct Client ID and Client Secret

### "Insufficient Permission"

**Solution:** During the authorization flow, make sure you selected the permission to "Send email on your behalf"

### Email not sending

**Solution:**
1. Check your `.env` file has all the variables set correctly
2. Make sure `FROM_EMAIL` matches the Gmail account you authorized
3. Try running the test connection command first

### "Connection refused" or network errors

**Solution:**
1. Check your internet connection
2. Make sure you're not behind a firewall blocking Google APIs
3. Try the test connection command again

---

## Security Notes

🔒 **Important Security Tips:**

1. **Never commit your `.env` file** to git (it's already in `.gitignore`)
2. **Keep your Client Secret private** - treat it like a password
3. **Keep your Refresh Token private** - it gives access to send emails as you
4. **For production**: Store these in Render's environment variables, not in your code
5. **OAuth Consent Screen**: While in development, your app will show as "unverified" - this is normal. For production use with many users, you'd need to verify your app with Google.

---

## For Production Deployment (Render)

When deploying to Render, you'll need to add these as environment variables:

1. Go to your Render dashboard
2. Select your web service
3. Go to "Environment" tab
4. Add these environment variables:
   - `GMAIL_CLIENT_ID` = your client ID
   - `GMAIL_CLIENT_SECRET` = your client secret
   - `GMAIL_REFRESH_TOKEN` = your refresh token
   - `FROM_EMAIL` = your Gmail address
   - `EMAIL_PROVIDER` = gmail
   - `APP_URL` = your production URL (e.g., https://coaching-assistant.onrender.com)

---

## Quick Reference Card

Save this for later:

```bash
# File locations
.env file: /coaching-assistant/.env
OAuth script: /coaching-assistant/lib/scripts/gmail_oauth_setup.rb

# Test commands
bin/rails email:test_connection
bin/rails email:send_test[email@example.com]

# Where to find credentials
Google Cloud Console: https://console.cloud.google.com/
Navigate to: APIs & Services > Credentials
```

---

## Complete .env Example

Here's what your `.env` file should look like when complete:

```bash
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres

# Email Provider Configuration
EMAIL_PROVIDER=gmail
FROM_EMAIL=your-email@gmail.com

# Gmail API Configuration
GMAIL_CLIENT_ID=123456789-abc123def456.apps.googleusercontent.com
GMAIL_CLIENT_SECRET=GOCSPX-abc123def456xyz789
GMAIL_REFRESH_TOKEN=1//0gABCDEF...your-long-refresh-token-here...

# Application URL
APP_URL=http://localhost:3000

# GitHub Configuration (for Phase 3)
GITHUB_TOKEN=your_github_personal_access_token
GITHUB_REPO=your_username/your_lessons_repo
GITHUB_BRANCH=main

# Redis Configuration (for Sidekiq)
REDIS_URL=redis://localhost:6379/0

# Streak Configuration
STREAK_MODE=pause

# Rails Configuration
RAILS_ENV=development
RACK_ENV=development
```

---

## What's Next?

Once your Gmail setup is complete and tested:

1. ✅ Create your first client via the admin interface
2. ✅ Send a one-off email with markdown content
3. ✅ Test the preview feature
4. ✅ Verify the email looks good on mobile and desktop

---

## Need Help?

If you encounter any issues:

1. Check the troubleshooting section above
2. Verify all environment variables are set correctly
3. Make sure you're using the same Google account throughout
4. Run the test commands to identify the specific issue
5. Check the Rails logs: `tail -f log/development.log`

---

That's it! Once you complete these steps, your application will be able to send beautiful HTML emails to your coaching clients via Gmail. 🎉

**Last updated:** Phase 7 (MVP Complete)

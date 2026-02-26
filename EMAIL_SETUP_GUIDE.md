# Email Notifications Setup Guide

## Overview
Email notifications are sent via Supabase Edge Functions using Resend API.

## Configuration Steps

### 1. Environment Variables (Supabase Dashboard)

Go to: **Supabase Dashboard → Your Project → Edge Functions → email-notifications → Environment Variables**

Add these variables:

```
RESEND_API_KEY=re_d3YaT6tH_PigFU1MMUWKRQ9BRcw7gVtCy
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... (your service role key)
EMAIL_FROM=notifications@approvnow.com
APP_URL=https://app.approvnow.com
```

**Important**: The `SUPABASE_SERVICE_ROLE_KEY` is different from `SUPABASE_ANON_KEY`. You can find it in:
- Supabase Dashboard → Project Settings → API → service_role key

### 2. Deploy Edge Function

```bash
# Install Supabase CLI if not already installed
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref poaontiyougqfzmzxerf

# Deploy the edge function
supabase functions deploy email-notifications

# Set environment variables
supabase secrets set RESEND_API_KEY=re_d3YaT6tH_PigFU1MMUWKRQ9BRcw7gVtCy
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=YOUR_SERVICE_ROLE_KEY_HERE
supabase secrets set EMAIL_FROM=notifications@approvnow.com
supabase secrets set APP_URL=https://app.approvnow.com
```

### 3. Apply Database Migration

The migration file `20240226_fix_profiles_rls_for_email_notifications.sql` adds a policy to allow the edge function to read user emails.

```bash
# Apply the migration
supabase db push
```

Or manually run in Supabase SQL Editor:
```sql
-- Allow service_role to view all profiles for email notifications
DROP POLICY IF EXISTS "Service role can view all profiles" ON profiles;
CREATE POLICY "Service role can view all profiles" ON profiles
  FOR SELECT USING (auth.jwt() ->> 'role' = 'service_role');
```

### 4. Verify Domain on Resend

Your domain `approvnow.com` is already verified on Resend. The sender email is:
- `notifications@approvnow.com`

This is configured as the default in the Edge Function.

### 5. Test Email Notifications

To test if email notifications are working:

1. Make sure your workspace is on **Pro plan**
2. Invite a user to your workspace
3. Check if the invitation email is sent

### Troubleshooting

**Problem**: "Email notifications are only available for Pro plan workspaces"
- **Solution**: Upgrade your workspace to Pro plan in the app

**Problem**: "Resend API key not configured"
- **Solution**: Set the `RESEND_API_KEY` environment variable in Supabase Dashboard

**Problem**: "Failed to get email for user"
- **Solution**: Check if the profiles table migration has been applied

**Problem**: Emails not being sent but no errors
- **Solution**: Check Supabase Edge Function logs: Dashboard → Edge Functions → email-notifications → Logs

### Files Modified

1. **lib/modules/notification/notification_service.dart** - Fixed table name from `users` to `profiles`
2. **supabase/functions/email-notifications/index.ts** - Updated to use service_role key to bypass RLS
3. **supabase/migrations/20240226_fix_profiles_rls_for_email_notifications.sql** - New migration to allow edge function access

### Email Types Supported

- **invitation** - Sent when inviting a user to workspace
- **approval_request** - Sent when a new request needs approval
- **approval_completed** - Sent when a request is fully approved
- **request_rejected** - Sent when a request is rejected

### Security Notes

- The Edge Function uses `SUPABASE_SERVICE_ROLE_KEY` to bypass RLS policies
- This is safe because Edge Functions run server-side and are not exposed to clients
- The service role key should NEVER be exposed in client-side code

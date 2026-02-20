# Approve Now - Supabase Edge Functions

This directory contains Supabase Edge Functions for the Approve Now app.

## Functions

### email-notifications
Handles sending email notifications for:
- Workspace invitations
- Approval requests
- Approval completions
- Request rejections

## Setup

### 1. Install Supabase CLI
```bash
brew install supabase/tap/supabase
```

### 2. Login to Supabase
```bash
supabase login
```

### 3. Link to your project
```bash
supabase link --project-ref poaontiyougqfzmzxerf
```

### 4. Set environment secrets
Go to Supabase Dashboard → Edge Functions → Manage Secrets and add:

```
SENDGRID_API_KEY=your_sendgrid_api_key
SENDGRID_INVITATION_TEMPLATE_ID=your_template_id
SENDGRID_APPROVAL_TEMPLATE_ID=your_template_id
SENDGRID_COMPLETED_TEMPLATE_ID=your_template_id
SENDGRID_REJECTION_TEMPLATE_ID=your_template_id
EMAIL_FROM=noreply@yourdomain.com
APP_URL=https://your-app-url.com
```

### 5. Deploy functions
```bash
supabase functions deploy email-notifications
```

## Testing

### Local testing
```bash
supabase functions serve email-notifications --env-file ./supabase/.env.local
```

### Invoke function
```bash
curl -i --location POST 'https://poaontiyougqfzmzxerf.supabase.co/functions/v1/email-notifications' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"type":"invitation","data":{"email":"test@example.com","workspaceName":"Test Workspace","inviterName":"John Doe","inviteToken":"abc123"}}'
```

## Notes

- If `SENDGRID_API_KEY` is not set, the function will return success but not send emails
- This allows the app to work without email configuration during development

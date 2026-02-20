# Firebase Functions Setup Guide

This guide will help you set up and deploy Firebase Functions for email notifications in Approve Now.

## Prerequisites

1. **Node.js** (v18 or later)
2. **Firebase CLI** installed globally
3. **SendGrid account** with API key
4. **Firebase project** already configured

## Installation

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

### 2. Login to Firebase

```bash
firebase login
```

### 3. Install Dependencies

```bash
cd functions
npm install
```

## Configuration

### 4. Set Firebase Configuration Values

You need to configure the following environment variables:

```bash
# SendGrid API Key (Required)
firebase functions:config:set sendgrid.key="YOUR_SENDGRID_API_KEY"

# App URL for deep links (Required)
firebase functions:config:set app.url="https://yourapp.com"
# Or for local testing:
# firebase functions:config:set app.url="http://localhost:5000"

# Email Configuration (Optional - uses defaults if not set)
firebase functions:config:set email.from="noreply@approvenow.app"
firebase functions:config:set email.replyto="support@approvenow.app"
```

### 5. Verify Your Domain with SendGrid

Before sending emails, you must verify your domain with SendGrid:

1. Log in to [SendGrid](https://sendgrid.com)
2. Go to Settings → Sender Authentication
3. Authenticate your domain
4. Add the DNS records to your domain provider
5. Wait for verification (can take up to 48 hours)

## Deployment

### 6. Deploy Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:sendInvitationEmail
```

### 7. Verify Deployment

Check the Firebase Console → Functions to see if functions are deployed successfully.

## Local Development

### 8. Run Functions Emulator

```bash
firebase emulators:start --only functions
```

The emulator will start at `http://localhost:5001`

### 9. Configure Flutter to Use Emulator

In your Flutter app, configure Firebase Functions to use the emulator:

```dart
import 'package:cloud_functions/cloud_functions.dart';

void setupEmulator() {
  if (kDebugMode) {
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  }
}
```

## Testing

### 10. Test Invitation Email

You can test the function using Firebase Console or curl:

```bash
# Get your function URL from Firebase Console
curl -X POST https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/sendInvitationEmail \
  -H "Content-Type: application/json" \
  -d '{
    "workspaceId": "test-workspace",
    "invitationId": "test-invitation",
    "email": "test@example.com",
    "role": "editor",
    "invitedBy": "user-id"
  }'
```

### 11. Monitor Logs

```bash
# View function logs
firebase functions:log

# View specific function logs
firebase functions:log --only sendInvitationEmail
```

## Firestore Security Rules

Ensure your Firestore security rules allow the functions to read/write:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow functions to manage invitations
    match /workspaces/{workspaceId}/invitations/{invitationId} {
      allow read, write: if request.auth != null;
      allow create: if request.auth != null && 
        exists(/databases/$(database)/documents/workspaces/$(workspaceId)/members/$(request.auth.uid));
    }
    
    // Allow functions to read workspace data
    match /workspaces/{workspaceId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **"SendGrid not configured" error**
   - Check that `sendgrid.key` is set correctly
   - Verify the API key has permissions to send emails

2. **Domain not verified**
   - Complete domain verification in SendGrid
   - Use a verified sender email address

3. **Functions not triggering**
   - Check Firestore document path is correct
   - Verify security rules allow function access
   - Check function logs for errors

4. **Emails not being received**
   - Check spam/junk folders
   - Verify recipient email address
   - Check SendGrid activity feed for delivery status

### Testing Without SendGrid

If you don't have SendGrid configured yet, the function will log the email content instead of sending:

```
SendGrid not configured. Email would have been sent: {...}
```

This is useful for development and testing.

## Production Checklist

- [ ] Domain verified with SendGrid
- [ ] Production API key configured
- [ ] App URL points to production domain
- [ ] Functions deployed to production
- [ ] Firestore security rules updated
- [ ] Deep links configured for production domain
- [ ] Error monitoring configured (e.g., Sentry)
- [ ] Rate limiting configured in SendGrid

## Costs

**Firebase Functions:**
- Free tier: 2 million invocations/month
- Paid: $0.40 per million invocations

**SendGrid:**
- Free tier: 100 emails/day
- Paid plans start at $14.95/month for 50,000 emails

**Firestore:**
- Charges apply for read/write operations
- Monitor usage to avoid unexpected costs

## Next Steps

1. Set up monitoring and alerting
2. Configure retry logic for failed emails
3. Add email analytics tracking
4. Implement email templates customization
5. Add unsubscribe functionality for notifications

## Support

- Firebase Functions docs: https://firebase.google.com/docs/functions
- SendGrid docs: https://docs.sendgrid.com/
- Troubleshooting: Check Firebase Console → Functions → Logs

# Firebase Functions Configuration for Approve Now

## Your Free Firebase Domain

**Primary URL:** `https://approve-now.web.app`

**Alternative:** `https://approve-now.firebaseapp.com`

---

## Setup Commands

### 1. Set your app URL (FREE - No domain purchase needed)

```bash
cd "/Users/cssee/Dev/Approve Now/functions"
firebase functions:config:set app.url="https://approve-now.web.app"
```

### 2. Set SendGrid API Key (You'll need to sign up for free)

```bash
firebase functions:config:set sendgrid.key="YOUR_SENDGRID_API_KEY"
```

**Get free SendGrid API key:**
1. Go to https://sendgrid.com/free/
2. Sign up for free account (100 emails/day)
3. Create API key with "Mail Send" permissions
4. Copy the key and use it above

### 3. Deploy Functions

```bash
firebase deploy --only functions
```

---

## ⚠️ Important Notes for FREE Setup

**Email Deliverability:**
- Without domain verification, emails may go to spam
- Use for testing only
- For production, buy a domain ($10-15/year) and verify with SendGrid

**Deep Links:**
- The invite links will work: `https://approve-now.web.app/invite?token=xxx`
- Users can click and open in the app
- Works on mobile with proper deep link configuration

---

## Testing Your Setup

After deployment, test with:

```bash
# Check if functions are deployed
firebase functions:list

# View logs
firebase functions:log --only sendInvitationEmail
```

---

## Want to Add Custom Domain Later?

When ready to upgrade:

1. Buy domain (Namecheap, Google Domains, etc.)
2. Add to Firebase Hosting: `firebase hosting:channel:deploy`
3. Verify domain with SendGrid
4. Update config: `firebase functions:config:set app.url="https://yourdomain.com"`
5. Redeploy functions

---

## Quick Reference

| Resource | URL |
|----------|-----|
| Firebase Console | https://console.firebase.google.com/project/approve-now |
| Your App (Web) | https://approve-now.web.app |
| Functions Base | https://us-central1-approve-now.cloudfunctions.net |

---

Last Updated: 2026-02-20

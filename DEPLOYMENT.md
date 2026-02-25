# Flutter Web Deployment to Vercel

## Setup Instructions

### 1. Create New Vercel Project for Flutter Web

```bash
# Install Vercel CLI if not already installed
npm i -g vercel

# Navigate to project root
cd /Users/cssee/Dev/Approve Now

# Login to Vercel (if needed)
vercel login

# Create new project - IMPORTANT: Use different name from landing-page
vercel --confirm
# When prompted:
# - Project name: approve-now-web (or approve-now-flutter)
# - Root directory: . (current directory)
# - Build command: ./build-web.sh
# - Output directory: build/web
```

### 2. Configure Environment Variables in Vercel Dashboard

Go to Vercel Dashboard → Your Project → Settings → Environment Variables

Add these variables:

| Variable | Value | Environment |
|----------|-------|-------------|
| `SUPABASE_URL` | Your Supabase URL | Production, Preview |
| `SUPABASE_ANON_KEY` | Your Supabase anon key | Production, Preview |
| `REVENUECAT_IOS_KEY` | RevenueCat iOS API key | Production, Preview |
| `REVENUECAT_ANDROID_KEY` | RevenueCat Android API key | Production, Preview |

### 3. Configure Custom Domain

1. Go to Vercel Dashboard → Your Flutter Project → Settings → Domains
2. Add domain: `app.approvnow.com`
3. Follow Vercel's DNS instructions to add CNAME record:
   - Type: CNAME
   - Name: app
   - Value: cname.vercel-dns.com

### 4. Deploy

```bash
# Deploy to production
vercel --prod

# Or push to Git and Vercel will auto-deploy
```

### 5. Update Supabase CORS (Important!)

Add these domains to your Supabase project CORS whitelist:

```
https://app.approvnow.com
https://approve-now-web.vercel.app  (Vercel default domain)
```

Go to: Supabase Dashboard → Project Settings → API → CORS Origins

### 6. Verify Deployment

After deployment, verify:
1. `https://app.approvnow.com` loads the Flutter app
2. Login works (test authentication flow)
3. Landing page buttons redirect correctly

## Project Structure

```
Approve Now/
├── vercel.json           # Vercel config for Flutter Web
├── build-web.sh          # Build script with env vars
├── .vercelignore         # Files to exclude from deployment
├── landing-page/         # Separate Vercel project
│   ├── vercel.json
│   └── index.html        # Updated with app.approvnow.com links
└── build/web/            # Flutter web build output (auto-generated)
```

## Troubleshooting

### Build fails with "flutter: command not found"
- Vercel doesn't have Flutter pre-installed
- You'll need to use a custom Docker image or GitHub Actions

**Alternative: Use GitHub Actions**

Create `.github/workflows/deploy-web.yml`:

```yaml
name: Deploy Flutter Web

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Build Web
        run: |
          flutter pub get
          flutter build web \
            --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
            --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }} \
            --dart-define=REVENUECAT_IOS_KEY=${{ secrets.REVENUECAT_IOS_KEY }} \
            --dart-define=REVENUECAT_ANDROID_KEY=${{ secrets.REVENUECAT_ANDROID_KEY }}
      
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          working-directory: ./build/web
```

### Environment variables not working
- Ensure variables are set in Vercel Dashboard (not just .env file)
- Redeploy after adding environment variables
- Check build logs to see if values are being passed

### CORS errors
- Add `app.approvnow.com` to Supabase CORS whitelist
- Add Vercel preview domains if needed

## Important Notes

1. **Keep mobile apps separate**: Flutter Web deployment doesn't affect iOS/Android
2. **Two Vercel projects**: One for landing page, one for Flutter Web
3. **Environment variables**: Must be set in Vercel Dashboard, not in code
4. **Custom domain**: Use `app.approvnow.com` for Flutter Web
5. **Supabase CORS**: Must whitelist the new domain

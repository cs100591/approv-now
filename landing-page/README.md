# Approve Now Landing Page

Static landing page for the Approve Now mobile app.

## Deployment to Vercel

### Option 1: Deploy via Vercel CLI

1. **Install Vercel CLI** (if not already installed):
   ```bash
   npm i -g vercel
   ```

2. **Navigate to the landing-page directory**:
   ```bash
   cd landing-page
   ```

3. **Deploy**:
   ```bash
   vercel
   ```

4. **For production deployment**:
   ```bash
   vercel --prod
   ```

### Option 2: Deploy via Git (Recommended)

1. **Commit the landing-page folder to your repository**:
   ```bash
   git add landing-page/
   git commit -m "Add landing page for Vercel deployment"
   git push
   ```

2. **Connect to Vercel**:
   - Go to [vercel.com](https://vercel.com)
   - Import your Git repository
   - Set the **Root Directory** to `landing-page`
   - Deploy!

### Option 3: Manual Upload

1. Go to [vercel.com](https://vercel.com)
2. Drag and drop the `landing-page` folder onto the dashboard
3. Vercel will automatically deploy it

## Structure

```
landing-page/
├── index.html      # Main landing page
├── vercel.json     # Vercel configuration
└── README.md       # This file
```

## Features

- Responsive design
- App Store & Google Play download buttons
- Feature highlights
- How it works section
- Call-to-action sections

## Customization

Edit `index.html` to update:
- App name and branding
- Feature descriptions
- App Store links (when available)
- Contact information

## Post-Deployment

After deployment, Vercel will provide you with:
- Production URL (e.g., `https://approve-now-landing.vercel.app`)
- Preview URLs for each deployment
- Automatic HTTPS
- Global CDN distribution
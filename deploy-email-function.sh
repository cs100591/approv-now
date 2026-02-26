#!/bin/bash

# Deploy Email Notifications Edge Function
# This script deploys the Supabase Edge Function with proper configuration

set -e

echo "🚀 Deploying Email Notifications Edge Function"
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null
then
    echo -e "${RED}❌ Supabase CLI is not installed${NC}"
    echo "Install it with: npm install -g supabase"
    exit 1
fi

echo -e "${GREEN}✅ Supabase CLI found${NC}"

# Check if logged in
echo "🔍 Checking Supabase login status..."
if ! supabase projects list > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Not logged in to Supabase${NC}"
    echo "Please login: supabase login"
    exit 1
fi

echo -e "${GREEN}✅ Logged in to Supabase${NC}"

# Check if project is linked
echo "🔗 Checking project link..."
if [ ! -f "supabase/config.toml" ]; then
    echo -e "${YELLOW}⚠️  Project not linked${NC}"
    echo "Linking to project: poaontiyougqfzmzxerf"
    supabase link --project-ref poaontiyougqfzmzxerf
fi

echo -e "${GREEN}✅ Project linked${NC}"

# Deploy the edge function
echo ""
echo "📦 Deploying Edge Function..."
supabase functions deploy email-notifications

# Set environment variables
echo ""
echo "🔧 Setting environment variables..."
echo -e "${YELLOW}Note: You'll need to provide your SUPABASE_SERVICE_ROLE_KEY${NC}"
echo "You can find it in: Supabase Dashboard → Project Settings → API → service_role key"
echo ""

read -p "Enter your SUPABASE_SERVICE_ROLE_KEY (starts with 'eyJ...'): " SERVICE_ROLE_KEY

if [ -z "$SERVICE_ROLE_KEY" ]; then
    echo -e "${RED}❌ Service role key is required${NC}"
    exit 1
fi

echo "Setting secrets..."
supabase secrets set RESEND_API_KEY=re_d3YaT6tH_PigFU1MMUWKRQ9BRcw7gVtCy
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="$SERVICE_ROLE_KEY"
supabase secrets set EMAIL_FROM=notifications@approvnow.com
supabase secrets set APP_URL=https://app.approvnow.com

echo -e "${GREEN}✅ Environment variables set${NC}"

# Apply database migration
echo ""
echo "🗄️  Applying database migration..."
supabase db push

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""
echo "📋 Summary:"
echo "  - Edge Function deployed: email-notifications"
echo "  - Environment variables configured"
echo "  - Database migration applied"
echo ""
echo "🧪 Test the setup:"
echo "  1. Invite a user to a Pro workspace"
echo "  2. Check Supabase Edge Function logs for any errors"
echo ""
echo "📖 For more details, see: EMAIL_SETUP_GUIDE.md"

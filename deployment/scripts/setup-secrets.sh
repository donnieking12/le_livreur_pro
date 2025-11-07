#!/bin/bash

# GitHub Secrets Setup Script for Le Livreur Pro
# This script helps you set up the required secrets for CI/CD

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 GitHub Secrets Setup for Le Livreur Pro${NC}"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI is not installed${NC}"
    echo -e "${YELLOW}Please install GitHub CLI: https://cli.github.com/${NC}"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ Not authenticated with GitHub CLI${NC}"
    echo -e "${YELLOW}Please run: gh auth login${NC}"
    exit 1
fi

echo -e "${GREEN}✅ GitHub CLI is authenticated${NC}"
echo ""

# Repository information
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo -e "${BLUE}Repository: $REPO${NC}"
echo ""

# Function to set a secret
set_secret() {
    local secret_name=$1
    local secret_description=$2
    local secret_value=""
    
    echo -e "${YELLOW}Setting up: $secret_name${NC}"
    echo -e "${BLUE}Description: $secret_description${NC}"
    
    # Check if secret already exists
    if gh secret list | grep -q "$secret_name"; then
        echo -e "${YELLOW}Secret $secret_name already exists. Overwrite? (y/N)${NC}"
        read -r overwrite
        if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
            echo -e "${BLUE}Skipping $secret_name${NC}"
            return
        fi
    fi
    
    echo -e "${YELLOW}Enter value for $secret_name (input will be hidden):${NC}"
    read -s secret_value
    
    if [[ -n "$secret_value" ]]; then
        echo "$secret_value" | gh secret set "$secret_name"
        echo -e "${GREEN}✅ Secret $secret_name set successfully${NC}"
    else
        echo -e "${RED}❌ Empty value, skipping $secret_name${NC}"
    fi
    echo ""
}

# Set up Android secrets
echo -e "${BLUE}📱 Android Deployment Secrets${NC}"
echo "================================"

set_secret "ANDROID_KEYSTORE" "Base64 encoded Android keystore file"
set_secret "ANDROID_KEY_ALIAS" "Android key alias"
set_secret "ANDROID_STORE_PASSWORD" "Android keystore password"
set_secret "ANDROID_KEY_PASSWORD" "Android key password"
set_secret "GOOGLE_PLAY_SERVICE_ACCOUNT" "Google Play Console service account JSON"

# Set up iOS secrets
echo -e "${BLUE}🍎 iOS Deployment Secrets${NC}"
echo "=========================="

set_secret "IOS_CERTIFICATES" "Base64 encoded iOS certificates (.p12 file)"
set_secret "IOS_CERTIFICATE_PASSWORD" "iOS certificate password"
set_secret "APPSTORE_ISSUER_ID" "App Store Connect API issuer ID"
set_secret "APPSTORE_KEY_ID" "App Store Connect API key ID"
set_secret "APPSTORE_PRIVATE_KEY" "App Store Connect API private key"

# Set up Firebase secrets
echo -e "${BLUE}🔥 Firebase Deployment Secrets${NC}"
echo "==============================="

set_secret "FIREBASE_SERVICE_ACCOUNT_STAGING" "Firebase service account for staging"
set_secret "FIREBASE_SERVICE_ACCOUNT_PROD" "Firebase service account for production"

# Set up Supabase secrets
echo -e "${BLUE}🗄️ Supabase Secrets${NC}"
echo "==================="

set_secret "SUPABASE_ACCESS_TOKEN" "Supabase access token for database migrations"

# Set up API secrets
echo -e "${BLUE}🔑 API Secrets${NC}"
echo "==============="

set_secret "PRODUCTION_SUPABASE_URL" "Production Supabase URL"
set_secret "PRODUCTION_SUPABASE_ANON_KEY" "Production Supabase anonymous key"
set_secret "PRODUCTION_GOOGLE_MAPS_API_KEY" "Production Google Maps API key"
set_secret "STAGING_SUPABASE_URL" "Staging Supabase URL"
set_secret "STAGING_SUPABASE_ANON_KEY" "Staging Supabase anonymous key"
set_secret "STAGING_GOOGLE_MAPS_API_KEY" "Staging Google Maps API key"

# Set up payment provider secrets
echo -e "${BLUE}💳 Payment Provider Secrets${NC}"
echo "============================"

set_secret "ORANGE_MONEY_API_KEY" "Orange Money API key"
set_secret "MTN_MOMO_API_KEY" "MTN Mobile Money API key"
set_secret "WAVE_API_KEY" "Wave API key"
set_secret "STRIPE_SECRET_KEY_PROD" "Stripe production secret key"
set_secret "STRIPE_SECRET_KEY_TEST" "Stripe test secret key"

echo -e "${GREEN}🎉 Secrets setup completed!${NC}"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. Verify all secrets are correctly set in your GitHub repository settings"
echo "2. Test your CI/CD pipeline with a test push"
echo "3. Configure your deployment environments (staging/production)"
echo ""
echo -e "${BLUE}🔗 GitHub Repository Secrets: https://github.com/$REPO/settings/secrets/actions${NC}"
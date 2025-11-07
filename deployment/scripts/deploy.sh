#!/bin/bash

# Le Livreur Pro Deployment Script
# Usage: ./deploy.sh [staging|production] [web|android|ios|all]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-staging}
PLATFORM=${2:-all}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${BLUE}🚀 Le Livreur Pro Deployment Script${NC}"
echo -e "${BLUE}Environment: $ENVIRONMENT${NC}"
echo -e "${BLUE}Platform: $PLATFORM${NC}"
echo ""

# Validate environment
if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    echo -e "${RED}❌ Invalid environment. Use 'staging' or 'production'${NC}"
    exit 1
fi

# Validate platform
if [[ "$PLATFORM" != "web" && "$PLATFORM" != "android" && "$PLATFORM" != "ios" && "$PLATFORM" != "all" ]]; then
    echo -e "${RED}❌ Invalid platform. Use 'web', 'android', 'ios', or 'all'${NC}"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n1 | cut -d' ' -f2)
echo -e "${GREEN}✅ Flutter version: $FLUTTER_VERSION${NC}"

# Navigate to project root
cd "$PROJECT_ROOT"

# Load environment configuration
echo -e "${YELLOW}📋 Loading environment configuration...${NC}"
if [[ -f "deployment/env/.env.$ENVIRONMENT" ]]; then
    cp "deployment/env/.env.$ENVIRONMENT" .env
    echo -e "${GREEN}✅ Environment configuration loaded${NC}"
else
    echo -e "${RED}❌ Environment configuration not found${NC}"
    exit 1
fi

# Install dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✅ Dependencies installed${NC}"

# Run tests
echo -e "${YELLOW}🧪 Running tests...${NC}"
if flutter test test/unit/ --reporter=compact; then
    echo -e "${GREEN}✅ Tests passed${NC}"
else
    echo -e "${RED}❌ Tests failed${NC}"
    if [[ "$ENVIRONMENT" == "production" ]]; then
        echo -e "${RED}Cannot deploy to production with failing tests${NC}"
        exit 1
    fi
fi

# Build and deploy based on platform
deploy_web() {
    echo -e "${YELLOW}🌐 Building web application...${NC}"
    flutter build web --release --web-renderer canvaskit
    
    if [[ "$ENVIRONMENT" == "production" ]]; then
        echo -e "${YELLOW}🚀 Deploying to production web hosting...${NC}"
        # Add your production web deployment command here
        # firebase deploy --project le-livreur-pro-prod
    else
        echo -e "${YELLOW}🚀 Deploying to staging web hosting...${NC}"
        # Add your staging web deployment command here
        # firebase deploy --project le-livreur-pro-staging
    fi
    
    echo -e "${GREEN}✅ Web deployment completed${NC}"
}

deploy_android() {
    echo -e "${YELLOW}🤖 Building Android application...${NC}"
    
    if [[ "$ENVIRONMENT" == "production" ]]; then
        # Build signed AAB for production
        flutter build appbundle --release
        echo -e "${YELLOW}🚀 Deploying to Google Play Store...${NC}"
        # Add your Play Store deployment command here
    else
        # Build APK for staging
        flutter build apk --release
        echo -e "${YELLOW}🚀 Deploying to internal testing...${NC}"
        # Add your internal testing deployment command here
    fi
    
    echo -e "${GREEN}✅ Android deployment completed${NC}"
}

deploy_ios() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${YELLOW}⚠️ iOS build requires macOS, skipping...${NC}"
        return
    fi
    
    echo -e "${YELLOW}🍎 Building iOS application...${NC}"
    cd ios && pod install && cd ..
    flutter build ios --release --no-codesign
    
    if [[ "$ENVIRONMENT" == "production" ]]; then
        echo -e "${YELLOW}🚀 Deploying to App Store...${NC}"
        # Add your App Store deployment command here
    else
        echo -e "${YELLOW}🚀 Deploying to TestFlight...${NC}"
        # Add your TestFlight deployment command here
    fi
    
    echo -e "${GREEN}✅ iOS deployment completed${NC}"
}

# Execute deployment based on platform selection
case $PLATFORM in
    "web")
        deploy_web
        ;;
    "android")
        deploy_android
        ;;
    "ios")
        deploy_ios
        ;;
    "all")
        deploy_web
        deploy_android
        deploy_ios
        ;;
esac

# Generate deployment report
echo ""
echo -e "${GREEN}🎉 Deployment Summary${NC}"
echo -e "${GREEN}====================${NC}"
echo -e "${GREEN}Environment: $ENVIRONMENT${NC}"
echo -e "${GREEN}Platform(s): $PLATFORM${NC}"
echo -e "${GREEN}Timestamp: $(date)${NC}"
echo -e "${GREEN}Flutter Version: $FLUTTER_VERSION${NC}"
echo ""

# Save deployment log
DEPLOYMENT_LOG="deployment/logs/deployment-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "deployment/logs"
echo "Deployment completed: $ENVIRONMENT - $PLATFORM - $(date)" >> "$DEPLOYMENT_LOG"

echo -e "${BLUE}📋 Deployment log saved to: $DEPLOYMENT_LOG${NC}"
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
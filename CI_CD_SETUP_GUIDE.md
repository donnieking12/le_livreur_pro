# CI/CD Pipeline Setup Guide for Le Livreur Pro

## Overview

This guide will help you set up a complete CI/CD pipeline for Le Livreur Pro using GitHub Actions. The pipeline includes automated testing, building, and deployment to multiple platforms.

## 🏗️ Pipeline Architecture

### Continuous Integration (CI)
- **Automated Testing**: Unit, widget, and integration tests
- **Code Quality**: Linting, formatting, and security scans
- **Multi-Platform Builds**: Android, iOS, and Web
- **Performance Testing**: Bundle size analysis and integration tests

### Continuous Deployment (CD)
- **Environment Management**: Staging and Production deployments
- **Multi-Platform Deployment**: Play Store, App Store, and Web hosting
- **Database Migrations**: Automated Supabase schema updates
- **Release Management**: Automated changelog generation and GitHub releases

## 📋 Prerequisites

### 1. Development Tools
- Flutter SDK 3.35.5+
- Git
- GitHub CLI (optional, for secrets setup)

### 2. Platform Requirements

#### Android
- Google Play Console developer account
- Android signing keystore
- Google Play Console API access

#### iOS
- Apple Developer Program membership
- iOS distribution certificates
- App Store Connect API key

#### Web
- Firebase hosting project (or preferred web hosting)

### 3. Third-Party Services
- Supabase project (staging and production)
- Firebase projects (staging and production)
- Google Maps API keys
- Payment provider API keys (Orange Money, MTN MoMo, Wave, etc.)

## 🔧 Setup Instructions

### Step 1: Repository Configuration

1. **Fork or clone the repository**:
   ```bash
   git clone https://github.com/donnieking12/le_livreur_pro.git
   cd le_livreur_pro
   ```

2. **Enable GitHub Actions**:
   - Go to your repository settings
   - Navigate to Actions > General
   - Ensure "Allow all actions and reusable workflows" is selected

### Step 2: Environment Setup

1. **Configure environment files**:
   ```bash
   # Staging environment
   cp deployment/env/.env.staging .env.staging
   
   # Production environment
   cp deployment/env/.env.production .env.production
   ```

2. **Update environment variables**:
   - Edit `.env.staging` and `.env.production`
   - Replace placeholder values with your actual API keys and URLs

### Step 3: Secrets Configuration

Run the automated secrets setup script:

```bash
chmod +x deployment/scripts/setup-secrets.sh
./deployment/scripts/setup-secrets.sh
```

Or manually set the following secrets in your GitHub repository settings:

#### Android Secrets
- `ANDROID_KEYSTORE`: Base64 encoded keystore file
- `ANDROID_KEY_ALIAS`: Key alias
- `ANDROID_STORE_PASSWORD`: Keystore password
- `ANDROID_KEY_PASSWORD`: Key password
- `GOOGLE_PLAY_SERVICE_ACCOUNT`: Service account JSON

#### iOS Secrets
- `IOS_CERTIFICATES`: Base64 encoded certificates (.p12)
- `IOS_CERTIFICATE_PASSWORD`: Certificate password
- `APPSTORE_ISSUER_ID`: App Store Connect API issuer ID
- `APPSTORE_KEY_ID`: App Store Connect API key ID
- `APPSTORE_PRIVATE_KEY`: App Store Connect API private key

#### Firebase Secrets
- `FIREBASE_SERVICE_ACCOUNT_STAGING`: Staging service account
- `FIREBASE_SERVICE_ACCOUNT_PROD`: Production service account

#### API Secrets
- `PRODUCTION_SUPABASE_URL`: Production Supabase URL
- `PRODUCTION_SUPABASE_ANON_KEY`: Production Supabase key
- `PRODUCTION_GOOGLE_MAPS_API_KEY`: Production Google Maps key
- `STAGING_SUPABASE_URL`: Staging Supabase URL
- `STAGING_SUPABASE_ANON_KEY`: Staging Supabase key
- `STAGING_GOOGLE_MAPS_API_KEY`: Staging Google Maps key

### Step 4: Platform-Specific Setup

#### Android Setup

1. **Generate signing key**:
   ```bash
   keytool -genkey -v -keystore android/app/keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias lelivreurpro
   ```

2. **Configure Google Play Console**:
   - Create service account in Google Cloud Console
   - Download service account JSON
   - Grant necessary permissions in Play Console

#### iOS Setup

1. **Create App Store Connect API Key**:
   - Log in to App Store Connect
   - Go to Users and Access > Keys
   - Create new API key with App Manager role

2. **Export certificates**:
   ```bash
   # Export distribution certificate
   security find-identity -v -p codesigning
   security export-certificate -c "iPhone Distribution" -t p12 -f certificate.p12
   ```

#### Web Setup

1. **Configure Firebase Hosting**:
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase init hosting
   ```

2. **Update firebase.json**:
   ```json
   {
     "hosting": {
       "public": "build/web",
       "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
       "rewrites": [
         {
           "source": "**",
           "destination": "/index.html"
         }
       ]
     }
   }
   ```

## 🚀 Usage

### Automated Triggers

#### Continuous Integration
- **Push to main/develop**: Runs full CI pipeline
- **Pull requests**: Runs tests and builds
- **Scheduled**: Daily security scans

#### Continuous Deployment
- **Tag push** (v*.*.*): Triggers production deployment
- **Manual trigger**: Deploy to staging or production
- **Release creation**: Automatically deploys to app stores

### Manual Deployment

1. **Using GitHub Actions**:
   - Go to Actions tab in your repository
   - Select "Continuous Deployment" workflow
   - Click "Run workflow"
   - Choose environment and trigger deployment

2. **Using deployment script**:
   ```bash
   # Deploy to staging
   ./deployment/scripts/deploy.sh staging all
   
   # Deploy to production
   ./deployment/scripts/deploy.sh production all
   
   # Deploy specific platform
   ./deployment/scripts/deploy.sh production android
   ```

## 📊 Monitoring and Reporting

### Build Status
- Check workflow status in GitHub Actions tab
- Monitor build artifacts and logs
- Review test coverage reports

### Deployment Status
- Track deployment progress in real-time
- Monitor app store review status
- Check web hosting deployment status

### Performance Monitoring
- Bundle size analysis reports
- Performance test results
- Integration test coverage

## 🔧 Maintenance

### Regular Tasks

1. **Update dependencies**:
   ```bash
   flutter pub upgrade
   ```

2. **Security updates**:
   ```bash
   dart pub deps --json | dart run security_audit
   ```

3. **Clean up artifacts**:
   - Remove old build artifacts from GitHub
   - Clean up old releases

### Troubleshooting

#### Common Issues

1. **Build failures**:
   - Check Flutter version compatibility
   - Verify environment variables
   - Review dependency conflicts

2. **Deployment failures**:
   - Verify secrets are correctly set
   - Check platform-specific configurations
   - Review API key permissions

3. **Test failures**:
   - Run tests locally first
   - Check test environment setup
   - Verify mock data and fixtures

#### Debug Commands

```bash
# Check Flutter configuration
flutter doctor -v

# Run tests locally
flutter test --coverage

# Build locally
flutter build apk --release
flutter build ios --release
flutter build web --release

# Check GitHub CLI authentication
gh auth status

# Validate secrets
gh secret list
```

## 📈 Optimization Tips

### Performance
- Use build caching for faster builds
- Parallelize tests and builds
- Optimize Docker images for faster CI

### Security
- Regularly rotate secrets and API keys
- Use least-privilege access for service accounts
- Enable branch protection rules

### Cost Management
- Optimize workflow triggers
- Use efficient runner types
- Clean up old artifacts regularly

## 🆘 Support

### Documentation
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Guide](https://docs.flutter.dev/deployment/cd)
- [Firebase Hosting Guide](https://firebase.google.com/docs/hosting)

### Community Resources
- [Flutter Community Discord](https://discord.gg/flutter)
- [GitHub Actions Community](https://github.com/actions/community)

### Issue Reporting
- Create issues in the repository for CI/CD problems
- Include workflow logs and error messages
- Tag issues with `ci/cd` label

---

## 📝 Checklist

Before going live, ensure:

- [ ] All secrets are properly configured
- [ ] Environment files are updated with production values
- [ ] Platform-specific setup is complete
- [ ] Tests are passing locally and in CI
- [ ] Deployment scripts are tested
- [ ] Monitoring and alerting are configured
- [ ] Documentation is updated

---

**Last Updated**: January 2025  
**Version**: 1.0.0  
**Maintainer**: Le Livreur Pro Development Team
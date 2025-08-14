# 🚀 Codemagic CI/CD Setup Guide for Le Livreur Pro

## 📋 Overview

This guide will help you set up Codemagic CI/CD for your Flutter project. Codemagic will handle building, testing, and deploying your app across multiple platforms automatically.

## 🎯 What We'll Set Up

- ✅ **Automated builds** for Android, iOS, and Web
- ✅ **Code quality checks** and testing
- ✅ **Automatic deployments** to app stores
- ✅ **Environment-specific builds** (dev, staging, production)
- ✅ **Build caching** for faster builds

## 🚀 Quick Start

### 1. Create Codemagic Account

1. Go to [codemagic.io](https://codemagic.io)
2. Sign up with your GitHub/GitLab/Bitbucket account
3. Connect your Le Livreur Pro repository

### 2. Configure Environment Variables

1. In Codemagic dashboard, go to **Teams** → **Your Team** → **Environment Variables**
2. Add the following variables from `env.example`:

#### **Required Variables:**
```bash
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
ENVIRONMENT=production
```

#### **Android Signing (Required for APK/AAB):**
```bash
CM_KEYSTORE_PATH=/tmp/keystore.jks
CM_KEY_ALIAS=your_key_alias
CM_KEYSTORE_PASSWORD=your_keystore_password
CM_KEY_PASSWORD=your_key_password
```

#### **iOS Signing (Required for IPA):**
```bash
CM_CERTIFICATE=/tmp/certificate.p12
CM_CERTIFICATE_PASSWORD=your_certificate_password
CM_PROVISIONING_PROFILE=/tmp/profile.mobileprovision
```

### 3. Upload Signing Files

#### **Android:**
1. Convert your keystore to base64:
   ```bash
   base64 -i your_keystore.jks | tr -d '\n' > keystore_base64.txt
   ```
2. Copy the content and paste it in Codemagic as `CM_KEYSTORE_PATH`

#### **iOS:**
1. Convert your certificate and profile to base64:
   ```bash
   base64 -i your_certificate.p12 > certificate_base64.txt
   base64 -i your_profile.mobileprovision > profile_base64.txt
   ```
2. Copy the contents to Codemagic

### 4. Configure Build Triggers

1. Go to **Workflows** → **le-livreur-pro-android**
2. Set up triggers:
   - **Push to main**: Build and deploy to production
   - **Push to develop**: Build and test
   - **Pull requests**: Run tests only

## 🔧 Workflow Configuration

### **Android Build Workflow**

The `le-livreur-pro-android` workflow will:
- Build APK and AAB files
- Sign with your keystore
- Upload to Google Play Console (internal testing)
- Generate build artifacts

### **iOS Build Workflow**

The `le-livreur-pro-ios` workflow will:
- Build IPA file
- Sign with your certificate
- Upload to TestFlight
- Generate build artifacts

### **Web Build Workflow**

The `le-livreur-pro-web` workflow will:
- Build web assets
- Deploy to Firebase Hosting
- Generate build artifacts

### **Testing Workflow**

The `le-livreur-pro-test` workflow will:
- Run unit tests
- Run integration tests
- Generate coverage reports
- Send results via email

### **Code Analysis Workflow**

The `le-livreur-pro-analyze` workflow will:
- Run Flutter analyze
- Run custom linting
- Generate analysis reports
- Send quality reports via email

## 📱 Platform-Specific Setup

### **Android Setup**

1. **Google Play Console:**
   - Create app in Google Play Console
   - Set up internal testing track
   - Configure app signing

2. **Build Configuration:**
   - Update `android/app/build.gradle.kts` with your package name
   - Set version code and name
   - Configure signing configs

### **iOS Setup**

1. **App Store Connect:**
   - Create app in App Store Connect
   - Set up TestFlight
   - Configure app signing

2. **Build Configuration:**
   - Update `ios/Runner/Info.plist` with your bundle ID
   - Set version and build number
   - Configure signing and capabilities

### **Web Setup**

1. **Firebase Hosting:**
   - Create Firebase project
   - Set up hosting
   - Configure custom domain (optional)

2. **Build Configuration:**
   - Update `web/index.html` with your app title
   - Configure PWA settings
   - Set up service worker

## 🔐 Security Best Practices

### **Environment Variables**
- ✅ Never commit sensitive data to git
- ✅ Use Codemagic's encrypted environment variables
- ✅ Rotate keys regularly
- ✅ Use different keys for dev/staging/prod

### **Signing Keys**
- ✅ Store keystores securely
- ✅ Use different keys for different environments
- ✅ Backup your signing keys
- ✅ Document key management process

### **API Keys**
- ✅ Use service accounts where possible
- ✅ Restrict API key permissions
- ✅ Monitor API usage
- ✅ Set up alerts for unusual activity

## 📊 Monitoring & Analytics

### **Build Metrics**
- Build success rate
- Build duration
- Resource usage
- Error frequency

### **Quality Metrics**
- Test coverage
- Code quality scores
- Security scan results
- Performance benchmarks

## 🚨 Troubleshooting

### **Common Issues**

1. **Build Failures:**
   - Check environment variables
   - Verify signing configurations
   - Review build logs
   - Check dependency versions

2. **Signing Issues:**
   - Verify keystore/certificate format
   - Check passwords and aliases
   - Ensure files are properly encoded

3. **Deployment Failures:**
   - Check app store credentials
   - Verify app configuration
   - Review store listing requirements

### **Debug Commands**

```bash
# Check Flutter version
flutter --version

# Verify dependencies
flutter pub deps

# Run local analysis
flutter analyze

# Test locally
flutter test

# Build locally
flutter build apk --release
```

## 📚 Additional Resources

- [Codemagic Documentation](https://docs.codemagic.io/)
- [Flutter CI/CD Best Practices](https://flutter.dev/docs/deployment/ci)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [iOS Code Signing](https://developer.apple.com/support/code-signing/)

## 🎉 Next Steps

1. **Set up Codemagic account** and connect repository
2. **Configure environment variables** and signing
3. **Test first build** with a simple commit
4. **Set up monitoring** and alerts
5. **Configure automatic deployments**

## 📞 Support

If you encounter issues:
1. Check Codemagic build logs
2. Review this documentation
3. Check Flutter and platform-specific docs
4. Contact Codemagic support

---

**Happy Building! 🚀**

Your Le Livreur Pro app will now build automatically on every commit, ensuring consistent quality and fast deployments.

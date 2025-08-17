# Le Livreur Pro 🚚

**Professional Delivery Service Platform for Côte d'Ivoire**

A comprehensive Flutter application that connects customers, couriers, partners, and administrators in a seamless delivery ecosystem.

## ✨ Features

### 🏠 **Multi-Profile Dashboard System**
- **Customer Dashboard**: Order management, delivery tracking, zone information
- **Courier Dashboard**: Available deliveries, earnings, performance metrics
- **Partner Dashboard**: Order management, analytics, business insights
- **Admin Dashboard**: System overview, user management, system settings

### 📱 **Core Functionality**
- **Authentication**: Secure login system with phone number verification
- **Order Management**: Create, track, and manage delivery orders
- **Real-time Tracking**: Live delivery tracking with status updates
- **Profile Management**: Comprehensive user profile and settings
- **Multi-language Support**: French (default) and English localization

### 🎨 **Modern UI/UX**
- **Material Design 3**: Latest Flutter design principles
- **Responsive Design**: Optimized for all screen sizes
- **Dark/Light Themes**: Automatic theme switching
- **Brand Colors**: Professional green and orange color scheme

## 🏗️ Architecture

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants
│   ├── models/            # Data models (User, DeliveryOrder)
│   └── services/          # Business logic services
├── features/              # Feature-based modules
│   ├── auth/             # Authentication
│   ├── home/             # Main dashboard
│   ├── orders/           # Order management
│   ├── tracking/         # Delivery tracking
│   ├── courier/          # Courier-specific features
│   └── profile/          # User profile management
├── shared/               # Shared components
│   ├── theme/           # App theming
│   ├── utils/           # Utility functions
│   └── widgets/         # Reusable widgets
└── main.dart            # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/le_livreur_pro.git
   cd le_livreur_pro
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code files**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Environment Setup
- **Supabase**: Configure your Supabase project credentials
- **Google Maps**: Add your Google Maps API key
- **Localization**: Translation files are in `assets/translations/`

### Build Configuration
- **Android**: NDK version 27.0.12077973
- **iOS**: Minimum iOS version 12.0
- **Web**: Responsive web support included

## 🚀 CI/CD with Codemagic

This project uses **Codemagic** for automated CI/CD pipelines, ensuring consistent builds and deployments across all platforms.

### **Automated Workflows**
- **Android Build**: APK/AAB generation with Google Play deployment
- **iOS Build**: IPA generation with TestFlight deployment  
- **Web Build**: Web assets with Firebase Hosting deployment
- **Testing**: Automated unit and integration tests
- **Code Quality**: Static analysis and linting

### **Quick Setup**
1. **Connect Repository**: Link your GitHub/GitLab/Bitbucket repo
2. **Configure Variables**: Set up environment variables and signing keys
3. **Trigger Builds**: Push to main/develop branches to trigger builds
4. **Monitor**: Track build progress and results in real-time

📖 **Full Setup Guide**: See [CODEMAGIC_SETUP.md](CODEMAGIC_SETUP.md) for detailed instructions.

## 📱 Screenshots

### Customer Dashboard
- Welcome card with user information
- Quick action buttons for new orders and tracking
- Recent orders with status indicators
- Delivery zone information and pricing

### Courier Dashboard
- Online/offline status toggle
- Daily statistics (deliveries, earnings, ratings)
- Available delivery opportunities
- Recent delivery history

### Order Management
- Order statistics and filtering
- Detailed order information
- Status tracking and updates
- Support and communication tools

### Delivery Tracking
- Real-time delivery status
- Courier information and contact
- Estimated arrival times
- Delivery history

## 🌍 Localization

The app supports multiple languages:
- **French (fr)**: Default language for Côte d'Ivoire
- **English (en)**: International support

Translation files are located in `assets/translations/`

## 🎨 Theming

### Color Scheme
- **Primary Green**: #2E7D32 (Brand color)
- **Accent Orange**: #FF9800 (Call-to-action)
- **Success Green**: #4CAF50 (Positive actions)
- **Warning Orange**: #FF9800 (Warnings)
- **Error Red**: #F44336 (Errors)

### Theme Modes
- **Light Theme**: Clean, professional appearance
- **Dark Theme**: Modern, eye-friendly interface
- **Auto Switch**: Follows system preferences

## 🔒 Security Features

- **Phone Number Authentication**: Secure login system
- **Data Encryption**: All sensitive data is encrypted
- **Permission Management**: Granular app permissions
- **Secure API Communication**: HTTPS with proper headers

## 📊 Performance Optimizations

- **Gradle Configuration**: Optimized build settings
- **Memory Management**: Efficient resource usage
- **Image Caching**: Optimized image loading
- **Lazy Loading**: On-demand content loading

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Build tests
flutter build apk --debug
flutter build web --release
```

## 📦 Build & Deploy

### Android APK
```bash
flutter build apk --release
```

### iOS App Store
```bash
flutter build ios --release
```

### Web Deployment
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check this README and code comments
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Join community discussions
- **Email**: support@lelivreurpro.ci

## 🗺️ Roadmap

### Phase 1 (Current) ✅
- [x] Multi-profile dashboard system
- [x] Basic authentication
- [x] Order management
- [x] Delivery tracking
- [x] Multi-language support

### Phase 2 (Next)
- [ ] Real-time notifications
- [ ] Payment integration
- [ ] Advanced analytics
- [ ] Partner portal

### Phase 3 (Future)
- [ ] AI-powered route optimization
- [ ] Blockchain integration
- [ ] IoT device support
- [ ] Advanced reporting

## 📝 Recent Changes & Updates

### Latest Commits (Current Session)
- **Gradle Build Optimization**: Enhanced build process with improved debugging and error handling
- **Physical Device Testing**: Simplified debugging for faster APK builds on physical devices
- **Build Scripts**: Added local build scripts (`build_local.bat` and `build_local.ps1`) for Windows development
- **Gradle Permissions**: Fixed and improved Gradle permissions handling with better error recovery
- **CI/CD Improvements**: Enhanced Codemagic configuration for more reliable builds

### Build System Enhancements
- **Local Build Scripts**: Windows batch and PowerShell scripts for local development
- **Gradle Debugging**: Comprehensive debugging steps with better error handling
- **Permission Management**: Improved Java environment checks and execution methods
- **Fast Debug APK**: Optimized for quick testing on physical devices

---

**Built with ❤️ for Côte d'Ivoire's delivery ecosystem**

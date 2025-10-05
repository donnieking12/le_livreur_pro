# Developer Onboarding Guide for Le Livreur Pro

## Welcome!
Welcome to the Le Livreur Pro development team! This guide will help you set up your development environment quickly and efficiently.

## Project Overview
Le Livreur Pro is a comprehensive delivery service platform designed specifically for the Ivorian market. It connects customers, couriers, restaurant partners, and administrators in a unified real-time delivery ecosystem.

### Key Features
- Customer order management
- Real-time courier tracking
- Multi-payment integration (Orange Money, MTN Money, Wave, etc.)
- Restaurant partner dashboard
- Admin analytics and management
- Multi-language support (French/English)

## Technical Stack
- **Frontend**: Flutter (Multi-platform support)
- **Backend**: Supabase (PostgreSQL + Real-time)
- **Authentication**: Phone-based OTP
- **Maps**: Google Maps Platform
- **Payments**: Integration with local payment providers
- **State Management**: Riverpod
- **Localization**: Easy Localization

## Prerequisites
Before starting, ensure you have:
- Windows 10/11 (64-bit)
- At least 8GB RAM
- At least 20GB free disk space
- Git installed
- Flutter SDK 3.0+

## Setup Process

### 1. Repository Setup
```bash
git clone https://github.com/your-org/le-livreur-pro.git
cd le_livreur_pro
```

### 2. Environment Configuration
The project comes with a pre-configured `.env` file. For production, you'll need to update:
- Supabase credentials
- Google Maps API key
- Payment gateway keys

### 3. Dependency Installation
```bash
flutter pub get
```

### 4. Visual Studio Installation (Windows Development)
For Windows development, install Visual Studio Community with "Desktop development with C++" workload.

### 5. Asset Structure Verification
Ensure all asset directories exist:
- `assets/icons/`
- `assets/images/`
- `assets/images/delivery/`
- `assets/images/payment/`
- `assets/lottie/`
- `assets/translations/`

## Development Workflow

### Daily Development
1. Pull latest changes
2. Run `flutter pub get` if dependencies were updated
3. Start development server:
   ```bash
   flutter run -d windows
   ```

### Testing
- Unit tests: `flutter test`
- Integration tests: `flutter test integration_test`
- Widget tests: `flutter test test/widget`

### Building
- Windows: `flutter build windows`
- Web: `flutter build web`
- Android: `flutter build apk`

## Project Structure
```
lib/
├── core/                     # Core business logic
│   ├── config/              # Configuration files
│   ├── models/              # Data models
│   ├── services/            # External services
│   ├── providers/           # Riverpod providers
│   └── utils/               # Utility functions
├── features/                # Feature modules
│   ├── auth/               # Authentication
│   ├── orders/             # Order management
│   ├── courier/            # Courier interface
│   ├── restaurant/         # Restaurant partner
│   ├── admin/              # Admin dashboard
│   └── tracking/           # Order tracking
├── shared/                  # Shared components
│   ├── theme/              # App theme
│   └── widgets/            # Reusable widgets
└── main.dart               # Entry point
```

## Configuration Files
- `.env`: Environment variables
- `pubspec.yaml`: Dependencies and assets
- `analysis_options.yaml`: Code analysis rules

## Scripts and Tools
The project includes several helper scripts:
- `dev_setup_assistant.ps1`: Interactive setup assistant
- `verify_project_config.dart`: Configuration verification
- `verify_asset_structure.dart`: Asset structure verification
- `complete_setup_verification.dart`: Complete setup verification

## Common Development Tasks

### Adding a New Feature
1. Create a new folder in `features/`
2. Follow the existing pattern for structure
3. Create models, services, and UI components
4. Add necessary routes in the navigation system
5. Write tests for your feature

### Database Schema Changes
1. Update the Supabase schema
2. Update corresponding models in `core/models/`
3. Update services that interact with the changed tables
4. Run tests to ensure compatibility

### Adding Translations
1. Update `assets/translations/en.json` and `assets/translations/fr.json`
2. Add new keys following the existing naming convention
3. Use in code with `tr('key_name')`

## Troubleshooting

### Build Issues
1. Run `flutter clean`
2. Run `flutter pub get`
3. Check that all asset directories exist

### Configuration Issues
1. Verify `.env` file exists and is properly configured
2. Check that all required environment variables are set

### Visual Studio Issues
1. Ensure "Desktop development with C++" workload is installed
2. Restart your computer after installation
3. Run `flutter doctor` to verify

## Best Practices

### Code Style
- Follow the existing code style
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Git Workflow
- Create feature branches from `develop`
- Write descriptive commit messages
- Squash commits when appropriate
- Create pull requests for code review

### Testing
- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for user workflows
- Aim for high test coverage

## Support and Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Documentation](https://supabase.io/docs)
- [Riverpod Documentation](https://riverpod.dev/docs)

### Team Contacts
- Lead Developer: [contact info]
- Backend Specialist: [contact info]
- UI/UX Designer: [contact info]

### Communication
- Slack channel: #le-livreur-pro-dev
- Weekly standups: Mondays 10:00 AM
- Code reviews: Asynchronous via GitHub PRs

## Next Steps
1. Complete the Visual Studio installation if not already done
2. Run the setup verification scripts
3. Build and run the application
4. Explore the codebase
5. Pick up your first task from the issue tracker

Welcome to the team!
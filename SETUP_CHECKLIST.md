# Le Livreur Pro Setup Checklist

## Prerequisites
- [ ] Flutter SDK 3.19.0+ installed (⚠️ Requires reinstallation due to corruption)
- [ ] Dart 3.0+ installed
- [ ] Supabase account created
- [ ] Access to Google Maps Platform (optional for now)

## Configuration
- [x] Created [.env](file:///c%3A/Development/le_livreur_pro/.env.template) file with Supabase credentials
- [x] Verified Supabase configuration is valid
- [ ] Configure Google Maps API key
- [ ] Configure payment gateway credentials

## Flutter Installation Fix
- [ ] ⚠️ Uninstall current Flutter SDK ([Guide](FIX_FLUTTER_INSTALLATION.md))
- [ ] Download fresh Flutter SDK
- [ ] Extract to clean location
- [ ] Update PATH environment variables
- [ ] Verify installation with `flutter doctor`
- [ ] Reinstall project dependencies with `flutter pub get`

## Database Setup
- [ ] Execute database schema in Supabase ([Guide](SUPABASE_SCHEMA_EXECUTION_GUIDE.md))
- [ ] Verify all tables created
- [ ] Verify custom types created
- [ ] Verify initial data inserted
- [ ] Test database connection with `dart test_supabase_connection.dart`

## Testing
- [ ] Run `flutter pub get` to install dependencies
- [ ] Run unit tests
- [ ] Run widget tests
- [ ] Run integration tests

## Application Execution
- [ ] Run application in development mode
- [ ] Test user registration
- [ ] Test order creation
- [ ] Test courier dashboard
- [ ] Test admin dashboard
- [ ] Test real-time updates

## Additional Services
- [ ] Configure Google Maps API key
- [ ] Configure Orange Money API
- [ ] Configure MTN Money API
- [ ] Configure Wave API
- [ ] Configure push notification services

## Production Preparation
- [ ] Review security settings
- [ ] Set up monitoring
- [ ] Configure backups
- [ ] Test deployment process
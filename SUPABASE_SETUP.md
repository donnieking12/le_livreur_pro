# Supabase Setup Instructions for Le Livreur Pro

## Prerequisites
- Supabase account (free tier available)
- Project access to Le Livreur Pro codebase

## Step 1: Create Supabase Project

1. **Visit Supabase**: https://supabase.com
2. **Sign Up/Login**: Use GitHub authentication (recommended)
3. **Create New Project**:
   - Project Name: `le-livreur-pro`
   - Database Password: Generate strong password (SAVE THIS!)
   - Region: Select closest to Côte d'Ivoire:
     - `West Europe (London)` - Recommended
     - `Central US` - Alternative

## Step 2: Set Up Database Schema

1. **Access SQL Editor**:
   - Go to your project dashboard
   - Click **"SQL Editor"** in left sidebar
   - Click **"New Query"**

2. **Execute Schema**:
   - Copy entire content from `supabase_schema.sql`
   - Paste into SQL Editor
   - Click **"Run"** to execute

3. **Verify Setup**:
   - Check **"Table Editor"** to see created tables
   - Should see: users, delivery_orders, restaurants, etc.

## Step 3: Get Credentials

1. **Navigate to Settings**:
   - Click **"Settings"** in sidebar
   - Go to **"API"** section

2. **Copy Credentials**:
   ```
   Project URL: https://your-project-id.supabase.co
   anon/public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

## Step 4: Update Environment Configuration

1. **Edit `.env` file** in project root:
   ```bash
   # Replace with your actual values
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

2. **Important**: Never commit `.env` to version control!

## Step 5: Test Connection

1. **Run the app**:
   ```bash
   flutter run -d chrome
   ```

2. **Navigate to Connection Test**:
   - Add route to test screen temporarily
   - Or run connection verification

3. **Verify Status**:
   - Configuration should show "Real" values
   - Connection test should succeed
   - Should show user count from database

## Step 6: Configure Row Level Security (Optional but Recommended)

The schema includes basic RLS policies. For production:

1. **Review Policies** in Supabase Dashboard → Authentication → Policies
2. **Customize** based on your security requirements
3. **Test** with different user roles

## Step 7: Set Up Authentication (Optional)

For full authentication setup:

1. **Configure Auth Providers**:
   - Go to Authentication → Providers
   - Configure phone/SMS authentication
   - Add your SMS provider credentials

2. **Update Auth Settings**:
   - Set up custom SMTP for emails
   - Configure redirect URLs
   - Set session timeout

## Troubleshooting

### Connection Issues
- Verify URL format: `https://project-id.supabase.co`
- Check anon key starts with `eyJ`
- Ensure no trailing spaces in credentials

### Schema Issues
- Verify all SQL executed successfully
- Check for error messages in SQL Editor
- Ensure PostGIS extension is enabled

### Permission Issues
- Verify RLS policies are configured
- Check user authentication status
- Ensure service role key for admin operations

## Next Steps After Setup

1. **Google Maps API** - Set up for location services
2. **Payment Integration** - Configure Ivorian payment providers
3. **Push Notifications** - Set up Firebase Cloud Messaging
4. **Production Deployment** - Configure production environment

## Security Checklist

- [ ] `.env` file added to `.gitignore`
- [ ] RLS policies configured and tested
- [ ] Service role key secured (server-side only)
- [ ] Database backups enabled
- [ ] SSL certificates configured
- [ ] API rate limiting enabled

## Support

For issues with this setup:
1. Check Supabase documentation: https://supabase.com/docs
2. Verify all steps completed correctly
3. Test with demo data first
4. Check network connectivity and firewall settings

---

## Production Considerations

- Use separate Supabase projects for development/production
- Set up automated backups
- Configure monitoring and alerts
- Implement proper error handling
- Set up staging environment for testing
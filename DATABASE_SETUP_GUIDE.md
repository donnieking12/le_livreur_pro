# Database Setup Guide - Step 1 to Production

## Overview
This guide will walk you through setting up your Supabase database for Le Livreur Pro - the critical first step to production readiness.

## Current Status
- ✅ Supabase project created (fnygxppfogfpwycbbhsv)
- ✅ Database schema designed and ready
- ⏳ **NEXT: Execute schema in production database**

## Step-by-Step Database Setup

### 1. Access Your Supabase Dashboard

1. Open your web browser and go to: https://app.supabase.com
2. Sign in with your account
3. Select your project: **fnygxppfogfpwycbbhsv**

### 2. Navigate to SQL Editor

1. In the left sidebar, click on **"SQL Editor"**
2. Click **"New query"** to create a new SQL editor window

### 3. Execute the Database Schema

1. Open the file `supabase_schema.sql` in your project
2. **Copy the ENTIRE content** (Ctrl+A, then Ctrl+C)
3. **Paste into the Supabase SQL Editor** (Ctrl+V)
4. **Click "Run"** at the bottom right of the editor

### 4. Verify Schema Execution

After running the schema, you should see:
- ✅ Multiple "Success" messages for each CREATE statement
- ✅ No error messages in red
- ✅ All tables and types created successfully

### 5. Test the Database Connection

1. Open terminal in your project directory
2. Run the connection test:
   ```bash
   dart test_supabase_connection.dart
   ```

Expected output:
```
🚀 Testing Supabase connection for Le Livreur Pro...
✅ Supabase client initialized successfully
✅ Database connection successful!
📊 Found 4 users in database
👥 Sample users:
   - Admin User (admin)
   - Test Customer (customer)
   - Test Courier (courier)
   - Test Partner (partner)
🏗️  Testing table structure...
   🏢 Restaurants table: 0 records
   📦 Orders table: 0 records
   💳 Payments table: 0 records
🎉 Le Livreur Pro Supabase setup is complete and working!
```

## What Gets Created

### Database Tables
- **users** - All system users (customers, couriers, partners, admins)
- **addresses** - User addresses with geolocation
- **restaurants** - Partner restaurant/business information
- **menu_categories** - Restaurant menu organization
- **menu_items** - Individual menu items with pricing
- **delivery_orders** - Core order management
- **order_items** - Order line items for marketplace orders
- **payments** - Payment transaction records
- **user_analytics** - User behavior tracking

### Custom Types
- **user_type** - customer, courier, partner, admin
- **delivery_status** - Order progression states
- **payment_status** - Payment states
- **payment_method** - Orange Money, MTN, Wave, etc.
- **order_type** - package or marketplace
- **address_type** - home, work, other

### Initial Test Data
- 4 test users (one for each role)
- Proper user relationships and constraints
- Ready for production data

## Next Steps After Database Setup

### Immediate (This Session)
1. ✅ Execute database schema
2. ✅ Verify connection and tables
3. 🔄 Update services to use real data instead of mocks

### Next Priority
1. 🗺️ Set up Google Maps API integration
2. 💳 Begin payment gateway integration
3. 🔐 Implement real authentication flow

## Troubleshooting

### If Schema Execution Fails
```sql
-- Check if extensions are available
SELECT * FROM pg_available_extensions WHERE name IN ('uuid-ossp', 'postgis');

-- If postgis fails, you can run without it initially
-- Just comment out the postgis extension line
```

### If Connection Test Fails
1. Double-check your project URL and keys in the test file
2. Ensure your internet connection is stable
3. Verify the schema was executed successfully in Supabase dashboard

### Common Issues
- **Permission Error**: Make sure you're using the correct Supabase project
- **Network Error**: Check your internet connection
- **Schema Error**: Ensure the entire schema was copied correctly

## Support
If you encounter any issues:
1. Check the Supabase dashboard for error messages
2. Review the exact error in terminal
3. Let me know the specific error message for help

---

**Status**: 🔄 Ready to execute
**Priority**: 🚨 CRITICAL - This must be completed first
**Time Required**: 5-10 minutes
**Difficulty**: Easy (copy, paste, run)
# Supabase Schema Execution Guide

This guide provides detailed step-by-step instructions for executing the Le Livreur Pro database schema in your Supabase project.

## Prerequisites

Before starting, ensure you have:
1. A Supabase account
2. Your Supabase project (fnygxppfogfpwycbbhsv) created
3. Access to the Supabase dashboard

## Step-by-Step Instructions

### Step 1: Access Supabase Dashboard

1. Open your web browser and go to [https://app.supabase.com](https://app.supabase.com)
2. Sign in with your Supabase account credentials
3. From the project list, select your project with ID: `fnygxppfogfpwycbbhsv`

### Step 2: Navigate to SQL Editor

1. In the left sidebar of your project dashboard, locate and click on "SQL Editor"
2. You'll see a page with options like "Getting Started", "Tables", "Triggers", etc.
3. Click on "New query" to open a new SQL editor window

### Step 3: Prepare the Schema

1. Open the file `supabase_schema.sql` from your Le Livreur Pro project folder
2. Select all content (Ctrl+A or Cmd+A)
3. Copy the entire content to your clipboard (Ctrl+C or Cmd+C)

### Step 4: Execute the Schema

1. Go back to the Supabase SQL Editor window
2. Paste the copied schema content into the editor (Ctrl+V or Cmd+V)
3. Review the content to ensure it's properly pasted
4. Click the "Run" button at the bottom of the editor

### Step 5: Monitor Execution

1. The execution will start, and you'll see a progress indicator
2. The schema execution might take a minute or two to complete
3. Watch for any error messages in the results panel

### Step 6: Verify Success

After successful execution, you should see:
- "Success" messages for each CREATE statement
- No error messages
- All tables and types created

## Verification Queries

Run these queries in the SQL Editor to verify your schema was created correctly:

### Check Tables
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

Expected tables:
- addresses
- delivery_orders
- menu_categories
- menu_items
- order_items
- payments
- restaurants
- user_analytics
- users

### Check Custom Types
```sql
SELECT typname 
FROM pg_type 
WHERE typtype = 'e' 
AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
```

Expected types:
- address_type
- delivery_status
- order_type
- payment_method
- payment_status
- user_type

### Check Initial Data
```sql
SELECT id, phone, full_name, user_type, is_verified 
FROM users 
ORDER BY created_at;
```

You should see 4 users:
- Admin User (admin)
- Test Customer (customer)
- Test Courier (courier)
- Test Partner (partner)

## Troubleshooting

### Common Issues and Solutions

1. **"Extension not found" errors**
   - Solution: Run CREATE EXTENSION commands individually before running the full schema
   - Execute this first:
     ```sql
     CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
     CREATE EXTENSION IF NOT EXISTS "postgis";
     ```

2. **Permission errors**
   - Solution: Ensure you're logged in as a user with sufficient privileges
   - Try refreshing the page and re-authenticating

3. **Syntax errors**
   - Solution: Check that the entire schema was copied correctly
   - Look for any missing semicolons or unmatched parentheses

4. **Timeout errors**
   - Solution: Try running the schema in smaller chunks
   - Split the schema into sections and run them separately

### Manual Chunk Execution

If you encounter issues with the full schema, try executing it in chunks:

1. **Extensions** (Run first)
   ```sql
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   CREATE EXTENSION IF NOT EXISTS "postgis";
   ```

2. **Custom Types**
   ```sql
   CREATE TYPE user_type AS ENUM ('customer', 'courier', 'partner', 'admin');
   CREATE TYPE delivery_status AS ENUM (
       'pending',
       'assigned',
       'courier_en_route',
       'picked_up',
       'in_transit',
       'arrived_destination',
       'delivered',
       'cancelled',
       'disputed'
   );
   -- ... (continue with other types)
   ```

3. **Tables** (Run table creation statements one by one)

4. **Indexes and Policies**

5. **Initial Data**

## Next Steps

After successfully executing the schema:

1. Test the connection with:
   ```bash
   dart test_supabase_connection.dart
   ```

2. Configure Google Maps API key in your [.env](file:///c%3A/Development/le_livreur_pro/.env.template) file

3. Run Flutter dependencies:
   ```bash
   flutter pub get
   ```

4. Start the development server:
   ```bash
   flutter run
   ```

## Support

If you continue to experience issues:

1. Check the Supabase documentation: [https://supabase.com/docs](https://supabase.com/docs)
2. Review the Supabase community forums: [https://github.com/supabase/supabase/discussions](https://github.com/supabase/supabase/discussions)
3. Refer to the Le Livreur Pro documentation:
   - [SUPABASE_CONFIG.md](file:///c%3A/Development/le_livreur_pro/SUPABASE_CONFIG.md)
   - [COMPLETE_SETUP_GUIDE.md](file:///c%3A/Development/le_livreur_pro/COMPLETE_SETUP_GUIDE.md)
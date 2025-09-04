# Executing the Database Schema in Supabase

## Prerequisites

Before executing the schema, ensure you have:

1. Created a Supabase project
2. Configured your environment variables in the [.env](file:///c%3A/Development/le_livreur_pro/.env.template) file
3. Have access to your Supabase project dashboard

## Steps to Execute the Schema

### 1. Access Supabase Dashboard

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Sign in to your account
3. Select your project (fnygxppfogfpwycbbhsv)

### 2. Open SQL Editor

1. In the left sidebar, click on "SQL Editor"
2. Click on "New query" to create a new SQL editor window

### 3. Copy and Execute Schema

1. Open the [supabase_schema.sql](file:///c%3A/Development/le_livreur_pro/supabase_schema.sql) file from this project
2. Copy the entire content
3. Paste it into the Supabase SQL Editor
4. Click "Run" to execute the schema

### 4. Verify Schema Execution

After execution, you should see the following tables created:
- `users`
- `addresses`
- `restaurants`
- `menu_categories`
- `menu_items`
- `delivery_orders`
- `order_items`
- `payments`
- `user_analytics`

And the following custom types:
- `user_type`
- `delivery_status`
- `payment_status`
- `payment_method`
- `order_type`
- `address_type`

### 5. Verify Initial Data

The schema includes initial test data for different user types:
- Admin User
- Test Customer
- Test Courier
- Test Partner

You can verify this data by running:
```sql
SELECT * FROM users;
```

## Troubleshooting

### Common Issues

1. **Extension errors**: If you get errors about extensions, make sure you're running the CREATE EXTENSION commands first
2. **Permission errors**: Ensure you're running as a user with sufficient privileges
3. **Syntax errors**: Make sure you're copying the entire schema without modifications

### Checking Schema Status

To verify all tables were created successfully:
```sql
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
```

To verify custom types:
```sql
SELECT typname FROM pg_type WHERE typtype = 'e' AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
```

## Next Steps

After successfully executing the schema:
1. Test the connection with `dart test_supabase_connection.dart`
2. Configure additional services (Google Maps, payment gateways)
3. Run the application with `flutter run`
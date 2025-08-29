#!/bin/bash

# Le Livreur Pro - Supabase Setup Script
# This script helps you set up your Supabase configuration

echo "🚀 Le Livreur Pro - Supabase Setup"
echo "=================================="
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found!"
    echo "Creating .env file from template..."
    cp .env.template .env
    echo "✅ .env file created!"
    echo ""
fi

echo "📋 Setup Instructions:"
echo ""
echo "1. Create a Supabase project:"
echo "   - Go to https://supabase.com"
echo "   - Click 'New Project'"
echo "   - Choose a name (e.g., 'le-livreur-pro')"
echo "   - Set a database password"
echo "   - Choose a region close to Côte d'Ivoire (Europe/Africa)"
echo ""

echo "2. Get your Supabase credentials:"
echo "   - In your Supabase dashboard, go to Settings > API"
echo "   - Copy the 'Project URL'"
echo "   - Copy the 'anon public' key"
echo ""

echo "3. Update your .env file:"
echo "   - Open the .env file in your editor"
echo "   - Replace 'https://your-project-id.supabase.co' with your Project URL"
echo "   - Replace 'your-anon-key-here' with your anon public key"
echo ""

echo "4. Set up the database:"
echo "   - In Supabase dashboard, go to SQL Editor"
echo "   - Run the SQL script from 'supabase_schema.sql'"
echo ""

echo "5. Test the connection:"
echo "   - Run 'flutter pub get'"
echo "   - Run 'flutter run'"
echo ""

echo "📁 Files created:"
echo "   - .env (environment configuration)"
echo "   - supabase_schema.sql (database schema)"
echo ""

echo "🔗 Useful links:"
echo "   - Supabase Dashboard: https://supabase.com/dashboard"
echo "   - Flutter Setup Guide: ./COMPLETE_SETUP_GUIDE.md"
echo ""

echo "Need help? Check the COMPLETE_SETUP_GUIDE.md file for detailed instructions."
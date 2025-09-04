# Google Maps API Setup Guide for Le Livreur Pro

## Overview
This guide will help you set up Google Maps API for the Le Livreur Pro delivery platform. The application requires several Google Maps APIs to function properly, including map display, geocoding, directions, and place search.

## Required APIs
1. Maps JavaScript API
2. Geocoding API
3. Directions API
4. Places API

## Step-by-Step Setup

### 1. Access Google Cloud Console
- Visit [Google Cloud Console](https://console.cloud.google.com/)
- Sign in with your Google account

### 2. Create a New Project
1. Click on the project dropdown at the top
2. Click "New Project"
3. Enter project name: `le-livreur-pro`
4. Click "Create"

### 3. Enable Required APIs
1. Navigate to "APIs & Services" > "Library"
2. Search for and enable each of these APIs:
   - Maps JavaScript API
   - Geocoding API
   - Directions API
   - Places API

### 4. Create API Credentials
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "API Key"
3. Copy the generated API key
4. Click "Restrict Key" for security:
   - Application restrictions: HTTP referrers
   - Add your domains: `localhost/*` for development
   - API restrictions: Select the specific APIs enabled above
   - Click "Save"

### 5. Update Environment Configuration
1. Open your `.env` file in the project root
2. Replace `YOUR_ACTUAL_GOOGLE_MAPS_API_KEY_HERE` with your actual API key
3. Save the file

## Security Best Practices
- Always restrict your API keys to specific domains and APIs
- Never commit API keys to version control
- Regularly monitor API usage in the Google Cloud Console
- Set up billing alerts to avoid unexpected charges

## Testing the Integration
After updating your API key:
1. Restart your development server
2. Test map functionality in the application
3. Verify that geocoding and directions are working properly

## Troubleshooting
If maps aren't loading:
1. Check that all required APIs are enabled
2. Verify API key restrictions match your domain
3. Ensure no typos in the API key in your `.env` file
4. Check browser console for specific error messages

## Billing Information
Google Maps APIs require a billing account but offer generous free tiers:
- Maps JavaScript API: $200 monthly credit
- Geocoding API: $200 monthly credit
- Directions API: $200 monthly credit

For more information, visit [Google Maps Platform Pricing](https://cloud.google.com/maps-platform/pricing/).
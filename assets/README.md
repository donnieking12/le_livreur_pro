# Le Livreur Pro - Assets

## Overview

This directory contains all visual assets for the Le Livreur Pro application.

## Current Status

✅ **Placeholder Assets Created** - Basic SVG placeholders for development
⏳ **Professional Assets Needed** - Replace with professional designs before launch

## Directory Structure

```
assets/
├── images/
│   ├── app_logo.svg              # Main app logo (1024x1024)
│   ├── empty_orders.svg          # Empty state illustration
│   ├── payment/
│   │   ├── orange_money.svg      # Orange Money logo
│   │   ├── mtn_money.svg         # MTN Money logo
│   │   ├── moov_money.svg        # Moov Money logo
│   │   └── wave.svg              # Wave logo
│   └── delivery/                 # Delivery status icons (TODO)
├── icons/                        # App icons (TODO)
├── lottie/                       # Loading animations (TODO)
└── translations/                 # Language files
    ├── en.json
    └── fr.json
```

## Placeholder Assets

### App Logo (`app_logo.svg`)

- **Size**: 1024x1024px
- **Format**: SVG
- **Description**: Orange delivery truck icon with "Le Livreur Pro" text
- **Usage**: App icon, splash screen, branding
- **Status**: ⚠️ Placeholder - needs professional design

### Payment Logos

All payment logos are simple colored rectangles with text:

- **Orange Money**: Orange background (#FF7900)
- **MTN Money**: Yellow background (#FFCC00)
- **Moov Money**: Blue background (#0066CC)
- **Wave**: Green background (#00D9A5)
- **Status**: ⚠️ Placeholders - replace with official logos

### Empty States

- **empty_orders.svg**: "No orders" illustration
- **Status**: ⚠️ Placeholder - needs better design

## TODO - Assets Needed

### High Priority (Before Launch)

- [ ] Professional app logo (1024x1024 PNG + SVG)
- [ ] Official payment method logos (get from providers)
- [ ] App icons for all platforms:
  - [ ] iOS (multiple sizes)
  - [ ] Android (multiple sizes)
  - [ ] Web (favicon, PWA icons)
- [ ] Loading animations (Lottie JSON):
  - [ ] Delivery truck animation
  - [ ] Order processing animation
  - [ ] Success animation

### Medium Priority

- [ ] Delivery status icons:
  - [ ] Pending
  - [ ] Assigned
  - [ ] En route
  - [ ] Picked up
  - [ ] In transit
  - [ ] Delivered
- [ ] Empty state illustrations:
  - [ ] No favorites
  - [ ] No notifications
  - [ ] No restaurants
- [ ] Onboarding images (3-4 screens)

### Low Priority (Nice to Have)

- [ ] Category icons for restaurants
- [ ] Achievement badges
- [ ] Promotional banners
- [ ] Social media assets

## Design Guidelines

### Brand Colors

- **Primary**: #FF6B35 (Orange)
- **Secondary**: #2C3E50 (Dark Blue)
- **Accent**: #00D9A5 (Green - for success states)
- **Error**: #E74C3C (Red)
- **Warning**: #F39C12 (Yellow)

### Typography

- **Primary Font**: Inter (or system default)
- **Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700)

### Icon Style

- **Style**: Rounded, modern, minimalist
- **Size**: 24x24dp base size
- **Stroke**: 2px
- **Format**: SVG preferred, PNG fallback

## How to Replace Placeholders

### 1. Get Professional Designs

- Hire a designer on Fiverr, Upwork, or 99designs
- Budget: ~$200-500 for complete asset package
- Provide brand colors and style guidelines

### 2. Payment Logos

- Contact each mobile money provider:
  - Orange Money: Request official logo usage guidelines
  - MTN Money: Download from MTN brand portal
  - Moov Money: Contact Moov CI for assets
  - Wave: Download from Wave brand kit
- Follow each provider's brand guidelines

### 3. App Icons

Use a tool like:

- **App Icon Generator**: https://appicon.co/
- **Icon Kitchen**: https://icon.kitchen/
- Upload your 1024x1024 logo and generate all sizes

### 4. Lottie Animations

- Create on LottieFiles: https://lottiefiles.com/
- Or hire animator on Fiverr
- Export as JSON and place in `assets/lottie/`

## Asset Optimization

Before adding final assets:

1. **Optimize SVGs**: Use SVGO or similar tool
2. **Compress PNGs**: Use TinyPNG or ImageOptim
3. **Optimize Lottie**: Keep file size < 100KB each
4. **Test on devices**: Ensure assets look good on all screen sizes

## License & Attribution

- Placeholder assets: Created for Le Livreur Pro (internal use only)
- Payment logos: Property of respective companies (use with permission)
- Professional assets: Ensure you have proper licensing

---

**Last Updated**: 2025-11-20
**Next Review**: When professional assets are ready

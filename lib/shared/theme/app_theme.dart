import 'package:flutter/material.dart';

class AppTheme {
  // Oripio Brand Colors
  static const Color primaryYellow = Color(0xFFFECD4C); // Main brand color
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color primaryOrange = Color(0xFFF05E36); // Warning/Alert color
  static const Color primaryGreen = Color(0xFF4ACA6F); // Success/Active color
  static const Color primaryDark = Color(0xFF070A10); // Text/Icons
  
  // Legacy colors for admin compatibility
  static const Color accentOrange = primaryOrange;
  static const Color accentOrangeDark = Color(0xFFE04327);
  
  // Extended Color Palette
  static const Color accentYellowLight = Color(0xFFFEDC6C);
  static const Color accentYellowDark = Color(0xFFE6B742);
  static const Color backgroundGrey = Color(0xFFF8F9FA);
  static const Color borderGrey = Color(0xFFE9ECEF);
  
  // Neutral Colors
  static const Color neutralGrey = Color(0xFF6C757D);
  static const Color neutralGreyLight = Color(0xFFADB5BD);
  static const Color neutralGreyDark = Color(0xFF495057);
  
  // Status Colors
  static const Color successGreen = primaryGreen;
  static const Color warningOrange = primaryOrange;
  static const Color errorRed = Color(0xFFDC3545);
  static const Color infoBlue = Color(0xFF0DCAF0);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryYellow,
        primaryContainer: accentYellowLight,
        secondary: primaryOrange,
        secondaryContainer: primaryGreen,
        surface: primaryWhite,
        background: backgroundGrey,
        error: errorRed,
        onPrimary: primaryDark,
        onSecondary: primaryWhite,
        onSurface: primaryDark,
        onBackground: primaryDark,
        onError: primaryWhite,
        outline: borderGrey,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryYellow,
        foregroundColor: primaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryDark,
        ),
        iconTheme: IconThemeData(color: primaryDark),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: primaryDark,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryYellow,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryYellow,
          side: const BorderSide(color: primaryYellow, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryYellow,
        foregroundColor: primaryDark,
        elevation: 4,
      ),
      
      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.all(8),
        color: primaryWhite,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryWhite,
        selectedItemColor: primaryYellow,
        unselectedItemColor: neutralGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryYellow,
        unselectedLabelColor: neutralGrey,
        indicatorColor: primaryYellow,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
        filled: true,
        fillColor: primaryWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Chip Theme
      chipTheme: const ChipThemeData(
        backgroundColor: backgroundGrey,
        selectedColor: primaryYellow,
        labelStyle: TextStyle(color: primaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryYellow,
        circularTrackColor: borderGrey,
        linearTrackColor: borderGrey,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryYellow,
        primaryContainer: accentYellowDark,
        secondary: primaryOrange,
        secondaryContainer: primaryGreen,
        surface: Color(0xFF1A1A1A),
        background: primaryDark,
        error: errorRed,
        onPrimary: primaryDark,
        onSecondary: primaryWhite,
        onSurface: primaryWhite,
        onBackground: primaryWhite,
        onError: primaryWhite,
        outline: Color(0xFF3A3A3A),
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: primaryWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryWhite,
        ),
        iconTheme: IconThemeData(color: primaryWhite),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: primaryDark,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryYellow,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryYellow,
          side: const BorderSide(color: primaryYellow, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryYellow,
        foregroundColor: primaryDark,
        elevation: 4,
      ),
      
      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.all(8),
        color: Color(0xFF2D2D2D),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: primaryYellow,
        unselectedItemColor: neutralGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryYellow,
        unselectedLabelColor: neutralGrey,
        indicatorColor: primaryYellow,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Chip Theme
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFF2D2D2D),
        selectedColor: primaryYellow,
        labelStyle: TextStyle(color: primaryWhite),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryYellow,
        circularTrackColor: Color(0xFF3A3A3A),
        linearTrackColor: Color(0xFF3A3A3A),
      ),
    );
  }

  // Status color helpers
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warningOrange;
      case 'confirmed':
      case 'picked_up':
      case 'in_transit':
        return primaryYellow;
      case 'delivered':
      case 'completed':
        return successGreen;
      case 'cancelled':
      case 'failed':
        return errorRed;
      default:
        return neutralGrey;
    }
  }

  // Priority color helpers
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return errorRed;
      case 'high':
        return warningOrange;
      case 'medium':
        return primaryYellow;
      case 'low':
        return primaryGreen;
      default:
        return neutralGrey;
    }
  }
}
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Matching Platform',
      debugShowCheckedModeBanner: false,
      
      // LIGHT THEME
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      
      // ATTRACTIVE DARK THEME
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        
        // Beautiful dark color scheme with vibrant accents
        colorScheme: const ColorScheme.dark(
          // Primary colors - Vibrant Purple/Blue gradient
          primary: Color(0xFF8B5CF6),           // Vibrant Purple
          primaryContainer: Color(0xFF6D28D9),  // Deep Purple
          
          // Secondary colors - Cyan/Teal accent
          secondary: Color(0xFF06B6D4),         // Cyan
          secondaryContainer: Color(0xFF0E7490), // Dark Cyan
          
          // Tertiary - Pink accent for special highlights
          tertiary: Color(0xFFEC4899),          // Hot Pink
          tertiaryContainer: Color(0xFFBE185D), // Deep Pink
          
          // Surface colors - Rich dark backgrounds
          surface: Color(0xFF1E1B2E),           // Deep Purple-Black
          surfaceContainerHighest: Color(0xFF2D2640),    // Slightly lighter purple
          
          // Text colors
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFE5E5E5),         // Light gray text
          onSurfaceVariant: Color(0xFFB4B4B4),  // Muted text
          
          // Error colors
          error: Color(0xFFEF4444),             // Bright red
          onError: Colors.white,
          
          // Outline
          outline: Color(0xFF4A4458),           // Subtle purple-gray
        ),
        
        // Scaffold background
        scaffoldBackgroundColor: const Color(0xFF0F0E1A),
        
        // AppBar theme
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF1E1B2E),
          foregroundColor: Colors.white,
        ),
        
        // Card theme
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF1E1B2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2D2640),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF8B5CF6),
              width: 2,
            ),
          ),
          labelStyle: const TextStyle(color: Color(0xFFB4B4B4)),
          hintStyle: const TextStyle(color: Color(0xFF6B6B6B)),
        ),
        
        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF8B5CF6),
          ),
        ),
        
        // Floating action button theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        
        // Chip theme
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF2D2640),
          selectedColor: const Color(0xFF8B5CF6),
          labelStyle: const TextStyle(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        
        // Divider theme
        dividerTheme: const DividerThemeData(
          color: Color(0xFF4A4458),
          thickness: 1,
        ),
        
        // Icon theme
        iconTheme: const IconThemeData(
          color: Color(0xFFE5E5E5),
        ),
        
        // Bottom navigation bar theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1B2E),
          selectedItemColor: Color(0xFF8B5CF6),
          unselectedItemColor: Color(0xFF6B6B6B),
          elevation: 0,
        ),
        
        // Text theme with beautiful typography
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.25,
          ),
          displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB4B4B4),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFFE5E5E5),
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFFE5E5E5),
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Color(0xFFB4B4B4),
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB4B4B4),
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B6B6B),
          ),
        ),
      ),
      
      // Use system theme by default (automatically switches based on device settings)
      themeMode: ThemeMode.system,
      
      home: const WelcomeScreen(),
    );
  }
}

// Helper class for custom gradient colors in your app
class AppGradients {
  // Primary gradient - Purple to Pink
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B5CF6), // Vibrant Purple
      Color(0xFFEC4899), // Hot Pink
    ],
  );
  
  // Secondary gradient - Blue to Cyan
  static const LinearGradient secondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6), // Blue
      Color(0xFF06B6D4), // Cyan
    ],
  );
  
  // Success gradient - Green to Emerald
  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981), // Green
      Color(0xFF059669), // Emerald
    ],
  );
  
  // Warning gradient - Orange to Yellow
  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF59E0B), // Orange
      Color(0xFFEAB308), // Yellow
    ],
  );
  
  // Card gradient - Subtle purple
  static LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFF1E1B2E),
      const Color(0xFF2D2640).withValues(alpha: 0.5),
    ],
  );
}
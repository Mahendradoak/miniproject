import 'package:flutter/material.dart';

/// Beautiful color palette for the Job Platform app
class AppColors {
  // ========== DARK MODE COLORS ==========
  
  // Primary colors - Vibrant Purple/Violet
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryPurpleDark = Color(0xFF6D28D9);
  static const Color primaryPurpleLight = Color(0xFFA78BFA);
  
  // Secondary colors - Cyan/Teal
  static const Color secondaryCyan = Color(0xFF06B6D4);
  static const Color secondaryCyanDark = Color(0xFF0E7490);
  static const Color secondaryCyanLight = Color(0xFF22D3EE);
  
  // Accent colors
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentPinkDark = Color(0xFFBE185D);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF59E0B);
  
  // Background colors
  static const Color darkBackground = Color(0xFF0F0E1A);
  static const Color darkSurface = Color(0xFF1E1B2E);
  static const Color darkSurfaceVariant = Color(0xFF2D2640);
  static const Color darkCard = Color(0xFF252136);
  
  // Text colors for dark mode
  static const Color textPrimary = Color(0xFFE5E5E5);
  static const Color textSecondary = Color(0xFFB4B4B4);
  static const Color textTertiary = Color(0xFF6B6B6B);
  static const Color textDisabled = Color(0xFF4A4458);
  
  // ========== GRADIENTS ==========
  
  /// Primary gradient - Purple to Pink
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, accentPink],
  );
  
  /// Secondary gradient - Blue to Cyan
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentBlue, secondaryCyan],
  );
  
  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
  
  /// Warning gradient
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentOrange, Color(0xFFEAB308)],
  );
  
  /// Card gradient with subtle glow
  static LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      darkSurface,
      darkSurfaceVariant.withValues(alpha:0.7),
    ],
  );
  
  /// Shimmer gradient for loading states
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, -0.5),
    end: Alignment(1.0, 0.5),
    colors: [
      Color(0xFF1E1B2E),
      Color(0xFF2D2640),
      Color(0xFF1E1B2E),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // ========== MATCH SCORE COLORS ==========
  
  /// Get color based on match percentage
  static Color getMatchColor(int percentage) {
    if (percentage >= 90) {
      return const Color(0xFF10B981); // Excellent - Green
    } else if (percentage >= 75) {
      return const Color(0xFF06B6D4); // Great - Cyan
    } else if (percentage >= 60) {
      return const Color(0xFF8B5CF6); // Good - Purple
    } else if (percentage >= 40) {
      return const Color(0xFFF59E0B); // Fair - Orange
    } else {
      return const Color(0xFFEF4444); // Poor - Red
    }
  }
  
  /// Get gradient based on match percentage
  static LinearGradient getMatchGradient(int percentage) {
    if (percentage >= 90) {
      return const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
      );
    } else if (percentage >= 75) {
      return const LinearGradient(
        colors: [Color(0xFF06B6D4), Color(0xFF0E7490)],
      );
    } else if (percentage >= 60) {
      return primaryGradient;
    } else if (percentage >= 40) {
      return warningGradient;
    } else {
      return const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
      );
    }
  }
  
  // ========== STATUS COLORS ==========
  
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusAccepted = Color(0xFF10B981);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusReviewing = Color(0xFF3B82F6);
  
  // ========== SHADOWS ==========
  
  /// Glow shadow for cards
  static BoxShadow glowShadow({
    Color color = primaryPurple,
    double opacity = 0.3,
    double blur = 20,
    double spread = 0,
  }) {
    return BoxShadow(
      color: color.withValues(alpha:opacity),
      blurRadius: blur,
      spreadRadius: spread,
      offset: const Offset(0, 4),
    );
  }
  
  /// Subtle shadow for elevation
  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withValues(alpha:0.1),
    blurRadius: 10,
    offset: const Offset(0, 2),
  );
}

/// Extension to easily apply gradients to Text widgets
extension GradientText on Text {
  Widget withGradient(Gradient gradient) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: this,
    );
  }
}

/// Helper widgets for gradient buttons
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient gradient;
  final EdgeInsets? padding;
  final double? width;
  final double height;
  final double borderRadius;
  
  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient = AppColors.primaryGradient,
    this.padding,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          AppColors.glowShadow(
            color: gradient.colors.first,
            opacity: 0.4,
            blur: 15,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Gradient container card
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final EdgeInsets? padding;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  
  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.padding,
    this.borderRadius = 16,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.cardGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha:0.1),
          width: 1,
        ),
        boxShadow: boxShadow ?? [AppColors.cardShadow],
      ),
      child: child,
    );
  }
}
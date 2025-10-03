import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import '../utils/responsive.dart';
import '../utils/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Float animation for decorative elements
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Pulse animation for glow effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = Responsive.isDesktop(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkBackground,
                    AppColors.darkSurface,
                    AppColors.primaryPurpleDark,
                  ]
                : [
                    const Color(0xFF667eea),
                    const Color(0xFF764ba2),
                    const Color(0xFFEC4899),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            _buildFloatingElements(),
            
            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 80 : 24,
                    vertical: 40,
                  ),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: isDesktop ? 1400 : double.infinity),
                    child: isDesktop
                        ? _buildDesktopLayout(isDark)
                        : _buildMobileLayout(isDark),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 100 + _floatAnimation.value,
              left: 50,
              child: _buildFloatingCircle(80, AppColors.primaryPurple.withValues(alpha:0.1)),
            ),
            Positioned(
              bottom: 150 + _floatAnimation.value * 1.5,
              right: 80,
              child: _buildFloatingCircle(120, AppColors.secondaryCyan.withValues(alpha:0.1)),
            ),
            Positioned(
              top: 300 + _floatAnimation.value * 0.8,
              right: 200,
              child: _buildFloatingCircle(60, AppColors.accentPink.withValues(alpha:0.1)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.3),
            blurRadius: 40,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          // Left side - Content
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            AppColors.glowShadow(
                              color: AppColors.primaryPurple,
                              opacity: 0.6,
                              blur: 40,
                              spread: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.work_outline,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),
                
                // Main title with gradient
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha:0.9),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'Find Your\nDream Job',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Subtitle
                Text(
                  'AI-powered job matching platform connecting\ntalent with opportunity. Join thousands of\nprofessionals finding their perfect career match.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha:0.9),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Stats
                Row(
                  children: [
                    _buildStatCard('50K+', 'Job Seekers', isDark),
                    const SizedBox(width: 32),
                    _buildStatCard('10K+', 'Active Jobs', isDark),
                    const SizedBox(width: 32),
                    _buildStatCard('5K+', 'Companies', isDark),
                  ],
                ),
                const SizedBox(height: 64),
                
                // Features
                _buildFeatureRow(
                  Icons.psychology,
                  'AI-Powered Matching',
                  'Smart algorithms find your perfect job match',
                ),
                const SizedBox(height: 24),
                _buildFeatureRow(
                  Icons.bolt,
                  'One-Click Apply',
                  'Apply to multiple jobs with a single profile',
                ),
                const SizedBox(height: 24),
                _buildFeatureRow(
                  Icons.trending_up,
                  'Career Growth',
                  'Track your progress and achieve your goals',
                ),
              ],
            ),
          ),
          const SizedBox(width: 100),
          
          // Right side - CTA Card
          Expanded(
            flex: 1,
            child: _buildCTACard(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Animated logo
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        AppColors.glowShadow(
                          color: AppColors.primaryPurple,
                          opacity: 0.6,
                          blur: 40,
                          spread: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.work_outline,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            
            // Title
            const Text(
              'Find Your\nDream Job',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Subtitle
            Text(
              'AI-powered job matching connecting\ntalent with opportunity',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha:0.9),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('50K+', 'Users', isDark),
                _buildStatCard('10K+', 'Jobs', isDark),
                _buildStatCard('5K+', 'Companies', isDark),
              ],
            ),
            const SizedBox(height: 48),
            
            // Features
            _buildFeatureRow(
              Icons.psychology,
              'AI Matching',
              'Smart job recommendations',
            ),
            const SizedBox(height: 20),
            _buildFeatureRow(
              Icons.bolt,
              'Quick Apply',
              'One-click applications',
            ),
            const SizedBox(height: 20),
            _buildFeatureRow(
              Icons.trending_up,
              'Track Progress',
              'Monitor your career growth',
            ),
            const SizedBox(height: 48),
            
            // CTA Card
            _buildCTACard(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCTACard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha:0.8)
            : Colors.white.withValues(alpha:0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? AppColors.primaryPurple.withValues(alpha:0.3)
              : Colors.white.withValues(alpha:0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.2),
            blurRadius: 50,
            spreadRadius: 10,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Get Started Today',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Join thousands finding their perfect career match',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textSecondary : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // Login button
          GradientButton(
            text: 'Sign In',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            gradient: AppColors.primaryGradient,
            height: 60,
          ),
          const SizedBox(height: 20),
          
          // Register button
          Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.primaryPurple : AppColors.primaryPurpleDark,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.primaryPurple : AppColors.primaryPurpleDark,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Trust indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user,
                size: 20,
                color: isDark ? AppColors.accentGreen : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                'Trusted by 50,000+ professionals',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondary : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha:0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 28,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha:0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
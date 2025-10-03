import 'package:flutter/foundation.dart';

class AppConstants {
  // Automatically detect environment
  static String get baseUrl {
    if (kIsWeb) {
      // Check if running in production
      if (kReleaseMode) {
        // Replace with your production API URL
        return 'https://your-api-domain.com/api';
      }
      // Development on web
      return 'http://localhost:5000/api';
    } else {
      // Mobile - use your backend URL
      // For Android emulator, use 10.0.2.2 instead of localhost
      // For iOS simulator, localhost works
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:5000/api';
      }
      return 'http://localhost:5000/api';
    }
  }
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String jobsEndpoint = '/jobs';
  static const String matchesEndpoint = '/jobs/matches';
  static const String applicationsEndpoint = '/applications';
  static const String profileEndpoint = '/profile/job-seeker';
  static const String meEndpoint = '/auth/me';
  
  // App Configuration
  static const String appName = 'Job Platform';
  static const String appVersion = '1.0.0';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  
  // Pagination
  static const int jobsPerPage = 20;
  static const int applicationsPerPage = 10;
  
  // Cache Duration
  static const Duration cacheExpiry = Duration(hours: 1);
}
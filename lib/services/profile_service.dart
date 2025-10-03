import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/profile.dart';

class ProfileService {
  final String baseUrl = AppConstants.baseUrl;

  // Get auth token from storage
  Future<String?> _getToken() async {
    // TODO: Get from secure storage
    return 'your-token-here';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all profiles for current user
  Future<Map<String, dynamic>> getAllProfiles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.profileEndpoint}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'profiles': data['jobSeeker']['profiles'] ?? [],
          'activeProfile': data['activeProfile'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load profiles',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Create new profile
  Future<Map<String, dynamic>> createProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.profileEndpoint}'),
        headers: await _getHeaders(),
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to create profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Update specific profile
  Future<Map<String, dynamic>> updateProfile(
    String profileId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${AppConstants.profileEndpoint}/$profileId'),
        headers: await _getHeaders(),
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Activate a profile
  Future<Map<String, dynamic>> activateProfile(String profileId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.profileEndpoint}/$profileId/activate'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to activate profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Duplicate profile
  Future<Map<String, dynamic>> duplicateProfile(String profileId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.profileEndpoint}/$profileId/duplicate'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to duplicate profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Delete profile
  Future<Map<String, dynamic>> deleteProfile(String profileId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${AppConstants.profileEndpoint}/$profileId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to delete profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
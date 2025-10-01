import 'dart:convert';
import 'api_service.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  // Get all profile versions
  Future<Map<String, dynamic>> getAllProfiles() async {
    try {
      final response = await _apiService.get('/profile/job-seeker', withAuth: true);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load profiles');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Get active profile only
  Future<Map<String, dynamic>> getActiveProfile() async {
    try {
      final response = await _apiService.get('/profile/job-seeker/active', withAuth: true);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load active profile');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Create new profile version
  Future<bool> createProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.post(
        '/profile/job-seeker',
        profileData,
        withAuth: true,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Update specific profile version
  Future<bool> updateProfile(String profileId, Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.put(
        '/profile/job-seeker/$profileId',
        profileData,
        withAuth: true,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Activate a profile version
  Future<bool> activateProfile(String profileId) async {
    try {
      final response = await _apiService.post(
        '/profile/job-seeker/$profileId/activate',
        {},
        withAuth: true,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Delete profile version
  Future<bool> deleteProfile(String profileId) async {
    try {
      final response = await _apiService.delete(
        '/profile/job-seeker/$profileId',
        withAuth: true,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Duplicate profile version
  Future<bool> duplicateProfile(String profileId) async {
    try {
      final response = await _apiService.post(
        '/profile/job-seeker/$profileId/duplicate',
        {},
        withAuth: true,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
import 'dart:convert';
import 'api_service.dart';
import '../models/profile.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  // Get all profile versions
  Future<JobSeekerProfile?> getAllProfiles() async {
    try {
      final response = await _apiService.get('/profile/job-seeker', withAuth: true);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['jobSeeker'] != null) {
          return JobSeekerProfile.fromJson(data['jobSeeker']);
        }
      } else if (response.statusCode == 404) {
        // No profile exists yet
        return null;
      }
      throw Exception('Failed to load profiles: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading profiles: ${e.toString()}');
    }
  }

  // Get active profile only
  Future<ProfileVersion?> getActiveProfile() async {
    try {
      final response = await _apiService.get('/profile/job-seeker/active', withAuth: true);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['profile'] != null) {
          return ProfileVersion.fromJson(data['profile']);
        }
      } else if (response.statusCode == 404) {
        // No active profile exists yet
        return null;
      }
      throw Exception('Failed to load active profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading active profile: ${e.toString()}');
    }
  }

  // Create new profile version
  Future<Map<String, dynamic>> createProfile(ProfileVersion profileData) async {
    try {
      final response = await _apiService.post(
        '/profile/job-seeker',
        profileData.toJson(),
        withAuth: true,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'jobSeeker': data['jobSeeker'] != null
              ? JobSeekerProfile.fromJson(data['jobSeeker'])
              : null,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to create profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error creating profile: ${e.toString()}',
      };
    }
  }

  // Update specific profile version
  Future<Map<String, dynamic>> updateProfile(
    String profileId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await _apiService.put(
        '/profile/job-seeker/$profileId',
        profileData,
        withAuth: true,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'profile': data['profile'] != null
              ? ProfileVersion.fromJson(data['profile'])
              : null,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error updating profile: ${e.toString()}',
      };
    }
  }

  // Activate a profile version
  Future<Map<String, dynamic>> activateProfile(String profileId) async {
    try {
      final response = await _apiService.post(
        '/profile/job-seeker/$profileId/activate',
        {},
        withAuth: true,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profile activated successfully',
          'activeProfile': data['activeProfile'] != null
              ? ProfileVersion.fromJson(data['activeProfile'])
              : null,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to activate profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error activating profile: ${e.toString()}',
      };
    }
  }

  // Delete profile version
  Future<Map<String, dynamic>> deleteProfile(String profileId) async {
    try {
      final response = await _apiService.delete(
        '/profile/job-seeker/$profileId',
        withAuth: true,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profile deleted successfully',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to delete profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error deleting profile: ${e.toString()}',
      };
    }
  }

  // Duplicate profile version
  Future<Map<String, dynamic>> duplicateProfile(String profileId) async {
    try {
      final response = await _apiService.post(
        '/profile/job-seeker/$profileId/duplicate',
        {},
        withAuth: true,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profile duplicated successfully',
          'newProfile': data['newProfile'] != null
              ? ProfileVersion.fromJson(data['newProfile'])
              : null,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to duplicate profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error duplicating profile: ${e.toString()}',
      };
    }
  }
}

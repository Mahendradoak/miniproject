import 'dart:convert';
import '../models/job.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class JobService {
  final ApiService _apiService = ApiService();

  Future<List<Job>> getAllJobs() async {
    try {
      final response = await _apiService.get(AppConstants.jobsEndpoint);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jobsList = data['jobs'] as List;
        return jobsList.map((job) => Job.fromJson(job)).toList();
      } else {
        throw Exception('Failed to load jobs');
      }
    } catch (e) {
      throw Exception('Error: ' + e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getMatchingJobs() async {
    try {
      final response = await _apiService.get(
        AppConstants.matchesEndpoint,
        withAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final matchesList = data['matches'] as List;
        
        return matchesList.map((match) {
          return {
            'job': Job.fromJson(match['job']),
            'matchScore': match['matchScore'],
          };
        }).toList();
      } else {
        throw Exception('Failed to load matching jobs');
      }
    } catch (e) {
      throw Exception('Error: ' + e.toString());
    }
  }

  Future<bool> applyToJob({
    required String jobId,
    required String coverLetter,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.applicationsEndpoint,
        {
          'jobId': jobId,
          'coverLetter': coverLetter,
        },
        withAuth: true,
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
  // Profile Management Methods
  Future<Map<String, dynamic>> getAllProfiles() async {
    try {
      final response = await _apiService.get('/profile/job-seeker', withAuth: true);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'profiles': data['jobSeeker']['profiles'],
          'activeProfile': data['activeProfile']
        };
      } else {
        throw Exception('Failed to load profiles');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<bool> activateProfile(String profileId) async {
    try {
      final response = await _apiService.post(
        '/profile/job-seeker/$profileId/activate',
        {},
        withAuth: true,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProfile(String profileId) async {
    try {
      final response = await _apiService.delete(
        '/profile/job-seeker/$profileId',
        withAuth: true,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> duplicateProfile(String profileId) async {
    try {
      final response = await _apiService.post(
        '/profile/job-seeker/$profileId/duplicate',
        {},
        withAuth: true,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

import 'dart:convert';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String userType,
    required Map<String, dynamic> profile,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.registerEndpoint,
        {
          'email': email,
          'password': password,
          'userType': userType,
          'profile': profile,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await _apiService.saveToken(data['token']);
        return {
          'success': true,
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ' + e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _apiService.saveToken(data['token']);
        return {
          'success': true,
          'user': User.fromJson(data['user']),
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ' + e.toString(),
      };
    }
  }

  Future<void> logout() async {
    await _apiService.deleteToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }
}

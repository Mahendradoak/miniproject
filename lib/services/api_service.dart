import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiService {
  final storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  Future<void> saveToken(String token) async {
    await storage.write(key: 'jwt_token', value: token);
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'jwt_token');
  }

  Future<Map<String, String>> getHeaders({bool withAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (withAuth) {
      String? token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer ' + token;
      }
    }

    return headers;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body, {bool withAuth = false}) async {
    final url = Uri.parse(AppConstants.baseUrl + endpoint);
    final headers = await getHeaders(withAuth: withAuth);
    
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String endpoint, {bool withAuth = false}) async {
    final url = Uri.parse(AppConstants.baseUrl + endpoint);
    final headers = await getHeaders(withAuth: withAuth);
    
    return await http.get(url, headers: headers);
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body, {bool withAuth = false}) async {
    final url = Uri.parse(AppConstants.baseUrl + endpoint);
    final headers = await getHeaders(withAuth: withAuth);
    
    return await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint, {bool withAuth = false}) async {
    final url = Uri.parse(AppConstants.baseUrl + endpoint);
    final headers = await getHeaders(withAuth: withAuth);
    
    return await http.delete(url, headers: headers);
  }
}

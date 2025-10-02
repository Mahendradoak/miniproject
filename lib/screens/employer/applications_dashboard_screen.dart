import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_service.dart';

class ApplicationsDashboardScreen extends StatefulWidget {
  const ApplicationsDashboardScreen({super.key});

  @override
  State<ApplicationsDashboardScreen> createState() => _ApplicationsDashboardScreenState();
}

class _ApplicationsDashboardScreenState extends State<ApplicationsDashboardScreen> {
  final ApiService _apiService = ApiService();
  final List<dynamic> _applications = [];
  bool _isLoading = true;
  final String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _apiService.get('/applications', withAuth: true);
      
      if (response.statusCode == 200) {
        final
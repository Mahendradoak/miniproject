import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_service.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _applications = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

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
        final data = jsonDecode(response.body);
        setState(() {
          _applications = data['applications'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateApplicationStatus(String applicationId, String newStatus) async {
    try {
      final response = await _apiService.put(
        '/applications/$applicationId/status',
        {'status': newStatus},
        withAuth: true,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application status updated'),
            backgroundColor: Colors.green,
          ),
        );
        _loadApplications();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<dynamic> get _filteredApplications {
    if (_filterStatus == 'all') return _applications;
    return _applications.where((app) => app['status'] == _filterStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.blue;
      case 'shortlisted':
        return Colors.purple;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', _applications.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    'pending',
                    _applications.where((a) => a['status'] == 'pending').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Reviewed',
                    'reviewed',
                    _applications.where((a) => a['status'] == 'reviewed').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Shortlisted',
                    'shortlisted',
                    _applications.where((a) => a['status'] == 'shortlisted').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Accepted',
                    'accepted',
                    _applications.where((a) => a['status'] == 'accepted').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Rejected',
                    'rejected',
                    _applications.where((a) => a['status'] == 'rejected').length,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredApplications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _filterStatus == 'all'
                                  ? 'No applications yet'
                                  : 'No $_filterStatus applications',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadApplications,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredApplications.length,
                          itemBuilder: (context, index) {
                            final application = _filteredApplications[index];
                            return _buildApplicationCard(application);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      selectedColor: Colors.blue[100],
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final job = application['jobId'];
    final candidate = application['jobSeekerId'];
    final status = application['status'] ?? 'pending';
    final matchScore = application['matchScore'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showApplicationDetails(application),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      candidate['profile']?['firstName']?.substring(0, 1)?.toUpperCase() ?? 'U',
                      style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${candidate['profile']?['firstName'] ?? ''} ${candidate['profile']?['lastName'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          candidate['email'] ?? '',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: matchScore >= 80 ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$matchScore% Match',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Applied for: ${job['title'] ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Applied ${_formatDate(application['appliedAt'])}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              if (status == 'pending') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateApplicationStatus(application['_id'], 'reviewed'),
                        child: const Text('Mark Reviewed'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateApplicationStatus(application['_id'], 'shortlisted'),
                        child: const Text('Shortlist'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showApplicationDetails(Map<String, dynamic> application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Application Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (application['coverLetter'] != null) ...[
                  const Text(
                    'Cover Letter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      application['coverLetter'],
                      style: const TextStyle(height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Update Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['pending', 'reviewed', 'shortlisted', 'accepted', 'rejected']
                      .map((status) => ChoiceChip(
                            label: Text(status),
                            selected: application['status'] == status,
                            selectedColor: _getStatusColor(status).withOpacity(0.3),
                            onSelected: (selected) {
                              if (selected) {
                                _updateApplicationStatus(application['_id'], status);
                                Navigator.pop(context);
                              }
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'recently';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else {
        return 'just now';
      }
    } catch (e) {
      return 'recently';
    }
  }
}
import 'package:flutter/material.dart';
import '../../services/job_service.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  final JobService _jobService = JobService();
  
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadApplications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    
    try {
      final applications = await _jobService.getApplications();
      
      setState(() {
        _applications = applications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading applications: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading applications: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredApplications() {
    if (_selectedFilter == 'all') return _applications;
    return _applications
        .where((app) => app['status'] == _selectedFilter)
        .toList();
  }

  int _getCountByStatus(String status) {
    if (status == 'all') return _applications.length;
    return _applications.where((app) => app['status'] == status).length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = _getFilteredApplications();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (index) {
            setState(() {
              _selectedFilter = [
                'all',
                'pending',
                'reviewed',
                'shortlisted',
                'rejected'
              ][index];
            });
          },
          tabs: [
            _buildTab('All', _getCountByStatus('all')),
            _buildTab('Pending', _getCountByStatus('pending')),
            _buildTab('Reviewed', _getCountByStatus('reviewed')),
            _buildTab('Shortlisted', _getCountByStatus('shortlisted')),
            _buildTab('Rejected', _getCountByStatus('rejected')),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadApplications,
              child: filteredApps.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredApps.length,
                      itemBuilder: (context, index) {
                        return _buildApplicationCard(filteredApps[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final job = application['jobId'];
    if (job == null) return const SizedBox.shrink();
    
    final status = application['status'] as String;
    final appliedAt = DateTime.parse(application['appliedAt'] ?? application['createdAt']);
    final matchScore = application['matchScore'] as int? ?? 0;
    
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final daysAgo = DateTime.now().difference(appliedAt).inDays;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showApplicationDetails(application),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.business, color: Colors.blue[700]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['company'] ?? 'Company',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job['title'] ?? 'Job Title',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          _capitalize(status),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.location_on,
                    job['location'] != null
                        ? '${job['location']['city'] ?? ''}, ${job['location']['state'] ?? ''}'
                        : 'Location not specified',
                  ),
                  _buildInfoChip(Icons.work, _capitalize(job['jobType'] ?? '')),
                  _buildInfoChip(
                    Icons.schedule,
                    daysAgo == 0 ? 'Today' : daysAgo == 1 ? '1 day ago' : '$daysAgo days ago',
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              if (matchScore > 0) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Match Score', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: matchScore / 100,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      matchScore >= 80 ? Colors.green : matchScore >= 60 ? Colors.orange : Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('$matchScore%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              
              if (status == 'shortlisted') ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.celebration, color: Colors.green[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Great news! You have been shortlisted!',
                          style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_selectedFilter == 'all' ? Icons.inbox : Icons.filter_list_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'all' ? 'No applications yet' : 'No $_selectedFilter applications',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'all'
                ? 'Start applying to jobs to see them here'
                : 'You do not have any $_selectedFilter applications',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'reviewed': return Colors.blue;
      case 'shortlisted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'accepted': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.schedule;
      case 'reviewed': return Icons.visibility;
      case 'shortlisted': return Icons.star;
      case 'rejected': return Icons.close;
      case 'accepted': return Icons.check_circle;
      default: return Icons.info;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showApplicationDetails(Map<String, dynamic> application) {
    final job = application['jobId'];
    final status = application['status'] as String;
    final appliedAt = DateTime.parse(application['appliedAt'] ?? application['createdAt']);
    final matchScore = application['matchScore'] as int? ?? 0;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(job['title'] ?? 'Job Title', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(job['company'] ?? 'Company', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Row(
                    children: [
                      Icon(_getStatusIcon(status), color: _getStatusColor(status)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Application Status', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text(_capitalize(status), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getStatusColor(status))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Applied On', _formatDate(appliedAt)),
                _buildDetailRow('Location', job['location'] != null ? '${job['location']['city'] ?? ''}, ${job['location']['state'] ?? ''}' : 'N/A'),
                _buildDetailRow('Job Type', _capitalize(job['jobType'] ?? '')),
                if (matchScore > 0) _buildDetailRow('Match Score', '$matchScore%'),
                const SizedBox(height: 24),
                if (application['coverLetter'] != null) ...[
                  const Text('Cover Letter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(application['coverLetter'], style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 24),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _withdrawApplication(application['_id']);
                        },
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text('Withdraw', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.work),
                        label: const Text('View Job'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _withdrawApplication(String applicationId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Application'),
        content: const Text('Are you sure you want to withdraw this application? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application withdrawn successfully'), backgroundColor: Colors.red),
        );
        _loadApplications();
      }
    }
  }
}

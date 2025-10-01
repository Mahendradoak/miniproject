import 'package:flutter/material.dart';
import '../../services/job_service.dart';
import 'profile_screen.dart';
class ProfileManagerScreen extends StatefulWidget {
  const ProfileManagerScreen({Key? key}) : super(key: key);

  @override
  State<ProfileManagerScreen> createState() => _ProfileManagerScreenState();
}

class _ProfileManagerScreenState extends State<ProfileManagerScreen> {
  final JobService _jobService = JobService();
  List<dynamic> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _jobService.getAllProfiles();
      setState(() {
        _profiles = result['profiles'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profiles: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _activateProfile(String profileId) async {
    final success = await _jobService.activateProfile(profileId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile activated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadProfiles();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to activate profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteProfile(String profileId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: const Text('Are you sure you want to delete this profile version?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _jobService.deleteProfile(profileId);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProfiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _duplicateProfile(String profileId) async {
    final success = await _jobService.duplicateProfile(profileId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile duplicated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadProfiles();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to duplicate profile. Maximum 5 profiles allowed.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Versions'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('No profiles yet'),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          ).then((_) => _loadProfiles());
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create First Profile'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue[50],
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You can create up to 5 profile versions for different job types. Active profile is used for job matching.',
                              style: TextStyle(color: Colors.blue[900]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _profiles.length,
                        itemBuilder: (context, index) {
                          final profile = _profiles[index];
                          final isActive = profile['isActive'] == true;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: isActive ? 4 : 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isActive ? Colors.green : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    profile['name'] ?? 'Unnamed Profile',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                if (isActive)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Text(
                                                      'ACTIVE',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            if (profile['description'] != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  profile['description'],
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildInfoChip(
                                        Icons.code,
                                        '${(profile['skills'] as List?)?.length ?? 0} skills',
                                      ),
                                      _buildInfoChip(
                                        Icons.work_history,
                                        '${(profile['experience'] as List?)?.length ?? 0} experiences',
                                      ),
                                      _buildInfoChip(
                                        Icons.school,
                                        '${(profile['education'] as List?)?.length ?? 0} education',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      if (!isActive)
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _activateProfile(profile['_id']),
                                            icon: const Icon(Icons.check_circle_outline, size: 18),
                                            label: const Text('Activate'),
                                          ),
                                        ),
                                      if (!isActive) const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _duplicateProfile(profile['_id']),
                                          icon: const Icon(Icons.copy, size: 18),
                                          label: const Text('Duplicate'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (_profiles.length > 1)
                                        IconButton(
                                          onPressed: () => _deleteProfile(profile['_id']),
                                          icon: const Icon(Icons.delete_outline),
                                          color: Colors.red,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _profiles.length < 5
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ).then((_) => _loadProfiles());
              },
              icon: const Icon(Icons.add),
              label: Text('New Profile (${_profiles.length}/5)'),
            )
          : null,
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blue[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}
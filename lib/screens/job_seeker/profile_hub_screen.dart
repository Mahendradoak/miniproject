import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../auth/login_screen.dart';
import 'personal_info_screen.dart';
import 'applications_screen.dart';
import 'experience_screen.dart';
import 'education_screen.dart';
import 'skills_screen.dart';
import 'projects_screen.dart';

class ProfileHubScreen extends StatefulWidget {
  const ProfileHubScreen({super.key});

  @override
  State<ProfileHubScreen> createState() => _ProfileHubScreenState();
}

class _ProfileHubScreenState extends State<ProfileHubScreen> {
  final AuthService _authService = AuthService();
  final JobService _jobService = JobService();
  
  Map<String, dynamic>? _profile;
  final int _applicationCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final profiles = await _jobService.getAllProfiles();
      if (profiles['success']) {
        setState(() {
          _profile = profiles['activeProfile'];
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
    
    setState(() => _isLoading = false);
  }

  int _calculateCompleteness() {
    if (_profile == null) return 0;
    
    int score = 0;
    if (_profile!['name'] != null && _profile!['name'].toString().isNotEmpty) score += 15;
    if (_profile!['skills'] != null && _profile!['skills'].isNotEmpty) score += 20;
    if (_profile!['experience'] != null && _profile!['experience'].isNotEmpty) score += 25;
    if (_profile!['education'] != null && _profile!['education'].isNotEmpty) score += 15;
    if (_profile!['desiredJobTypes'] != null && _profile!['desiredJobTypes'].isNotEmpty) score += 10;
    if (_profile!['desiredSalary'] != null) score += 10;
    if (_profile!['preferredLocations'] != null && _profile!['preferredLocations'].isNotEmpty) score += 5;
    
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final completeness = _calculateCompleteness();
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                await _authService.logout();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile Overview Card
                    _buildProfileCard(completeness),
                    const SizedBox(height: 24),
                    
                    // Quick Stats
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    
                    // Profile Sections
                    _buildSectionTitle('Profile Sections'),
                    const SizedBox(height: 12),
                    _buildProfileTile(
                      icon: Icons.person,
                      title: 'Personal Information',
                      subtitle: 'Name, email, phone, location',
                      color: Colors.blue,
                      onTap: () => _navigateTo(const PersonalInfoScreen()),
                    ),
                    _buildProfileTile(
                      icon: Icons.work,
                      title: 'Work Experience',
                      subtitle: '${_profile?['experience']?.length ?? 0} entries',
                      color: Colors.orange,
                      onTap: () => _navigateTo(const ExperienceScreen()),
                    ),
                    _buildProfileTile(
                      icon: Icons.folder,
                      title: 'Projects',
                      subtitle: 'Showcase your work',
                      color: Colors.purple,
                      onTap: () => _navigateTo(const ProjectsScreen()),
                    ),
                    _buildProfileTile(
                      icon: Icons.school,
                      title: 'Education',
                      subtitle: '${_profile?['education']?.length ?? 0} entries',
                      color: Colors.green,
                      onTap: () => _navigateTo(const EducationScreen()),
                    ),
                    _buildProfileTile(
                      icon: Icons.build,
                      title: 'Skills',
                      subtitle: '${_profile?['skills']?.length ?? 0} skills',
                      color: Colors.teal,
                      onTap: () => _navigateTo(const SkillsScreen()),
                    ),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Applications & Activity'),
                    const SizedBox(height: 12),
                    _buildProfileTile(
                      icon: Icons.description,
                      title: 'My Applications',
                      subtitle: '$_applicationCount applications',
                      color: Colors.indigo,
                      badge: _applicationCount > 0 ? _applicationCount.toString() : null,
                      onTap: () => _navigateTo(const ApplicationsScreen()),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard(int completeness) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar (Simple Icon)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: completeness >= 80 ? Colors.green[100] : Colors.orange[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 60,
                color: completeness >= 80 ? Colors.green[700] : Colors.orange[700],
              ),
            ),
            const SizedBox(height: 16),
            
            // Name
            Text(
              _profile?['name'] ?? 'Complete Your Profile',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Profile Completeness
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Profile $completeness% Complete',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  completeness >= 80 ? Icons.verified : Icons.warning_amber,
                  size: 18,
                  color: completeness >= 80 ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completeness / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  completeness >= 80 ? Colors.green : Colors.orange,
                ),
              ),
            ),
            
            if (completeness < 100) ...[
              const SizedBox(height: 12),
              Text(
                '${100 - completeness}% to go for a complete profile',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.work_outline,
            label: 'Applications',
            value: _applicationCount.toString(),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star_outline,
            label: 'Skills',
            value: (_profile?['skills']?.length ?? 0).toString(),
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            label: 'Experience',
            value: (_profile?['experience']?.length ?? 0).toString(),
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    _loadProfile(); // Refresh after returning
  }
}

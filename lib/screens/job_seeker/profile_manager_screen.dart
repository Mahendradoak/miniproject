import 'package:flutter/material.dart';
import '../../services/profile_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive.dart';
import 'profile_editor_screen.dart';

class ProfilesManagerScreen extends StatefulWidget {
  const ProfilesManagerScreen({super.key});

  @override
  State<ProfilesManagerScreen> createState() => _ProfilesManagerScreenState();
}

class _ProfilesManagerScreenState extends State<ProfilesManagerScreen> {
  final ProfileService _profileService = ProfileService();
  List<dynamic> _profiles = [];
  dynamic _activeProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);

    final result = await _profileService.getAllProfiles();

    if (result['success']) {
      setState(() {
        _profiles = result['profiles'] ?? [];
        _activeProfile = result['activeProfile'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      _showError(result['error']);
    }
  }

  Future<void> _activateProfile(String profileId) async {
    final result = await _profileService.activateProfile(profileId);

    if (result['success']) {
      _showSuccess('Profile activated successfully');
      await _loadProfiles();
    } else {
      _showError(result['error']);
    }
  }

  Future<void> _duplicateProfile(String profileId) async {
    final result = await _profileService.duplicateProfile(profileId);

    if (result['success']) {
      _showSuccess('Profile duplicated successfully');
      await _loadProfiles();
    } else {
      _showError(result['error']);
    }
  }

  Future<void> _deleteProfile(String profileId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: const Text('Are you sure you want to delete this profile? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _profileService.deleteProfile(profileId);

      if (result['success']) {
        _showSuccess('Profile deleted successfully');
        await _loadProfiles();
      } else {
        _showError(result['error']);
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.accentPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profiles'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        actions: [
          if (_profiles.length < 5)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileEditorScreen(),
                  ),
                ).then((_) => _loadProfiles());
              },
              tooltip: 'Create New Profile',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfiles,
              child: _profiles.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildProfilesList(isDark, isDesktop),
            ),
      floatingActionButton: _profiles.length < 5
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileEditorScreen(),
                  ),
                ).then((_) => _loadProfiles());
              },
              backgroundColor: AppColors.primaryPurple,
              icon: const Icon(Icons.add),
              label: const Text('New Profile'),
            )
          : null,
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Profiles Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create different profiles for different job types.\nYou can have up to 5 profiles.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.textSecondary : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            GradientButton(
              text: 'Create Your First Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileEditorScreen(),
                  ),
                ).then((_) => _loadProfiles());
              },
              gradient: AppColors.primaryGradient,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilesList(bool isDark, bool isDesktop) {
    return ListView(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      children: [
        // Header with stats
        _buildHeader(isDark),
        const SizedBox(height: 24),

        // Profiles grid/list
        if (isDesktop)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.5,
            ),
            itemCount: _profiles.length,
            itemBuilder: (context, index) => _buildProfileCard(
              _profiles[index],
              isDark,
            ),
          )
        else
          ..._profiles.map((profile) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildProfileCard(profile, isDark),
              )),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          AppColors.glowShadow(
            color: AppColors.primaryPurple,
            opacity: 0.3,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have ${_profiles.length} profile${_profiles.length != 1 ? 's' : ''} • ${5 - _profiles.length} remaining',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_profiles.where((p) => p['isActive'] == true).length}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(dynamic profile, bool isDark) {
    final isActive = profile['isActive'] == true;
    final profileId = profile['_id'];
    final name = profile['name'] ?? 'Unnamed Profile';
    final description = profile['description'] ?? 'No description';
    final skills = (profile['skills'] as List?)?.length ?? 0;
    final experience = (profile['experience'] as List?)?.length ?? 0;

    return GradientCard(
      gradient: isActive
          ? AppColors.primaryGradient
          : (isDark ? AppColors.cardGradient : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: isActive
                      ? Colors.white
                      : (isDark ? AppColors.textSecondary : Colors.grey[600]),
                ),
                itemBuilder: (context) => [
                  if (!isActive)
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_outline),
                          SizedBox(width: 12),
                          Text('Set as Active'),
                        ],
                      ),
                      onTap: () => _activateProfile(profileId),
                    ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileEditorScreen(
                            profileId: profileId,
                            initialData: profile,
                          ),
                        ),
                      ).then((_) => _loadProfiles());
                    },
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 12),
                        Text('Duplicate'),
                      ],
                    ),
                    onTap: () => _duplicateProfile(profileId),
                  ),
                  if (!isActive)
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () => _deleteProfile(profileId),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Profile name
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? Colors.white
                  : (isDark ? AppColors.textPrimary : Colors.black87),
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: isActive
                  ? Colors.white70
                  : (isDark ? AppColors.textSecondary : Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              _buildStat(
                Icons.code,
                '$skills Skills',
                isActive,
                isDark,
              ),
              const SizedBox(width: 16),
              _buildStat(
                Icons.work_outline,
                '$experience Experience',
                isActive,
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action button
          if (!isActive)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _activateProfile(profileId),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.primaryPurple : AppColors.primaryPurpleDark,
                  side: BorderSide(
                    color: isDark ? AppColors.primaryPurple : AppColors.primaryPurpleDark,
                  ),
                ),
                child: const Text('Set as Active'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, bool isActive, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isActive
              ? Colors.white70
              : (isDark ? AppColors.textTertiary : Colors.grey[500]),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isActive
                ? Colors.white70
                : (isDark ? AppColors.textSecondary : Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
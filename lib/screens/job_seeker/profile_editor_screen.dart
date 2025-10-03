import 'package:flutter/material.dart';
import '../../services/profile_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive.dart';

class ProfileEditorScreen extends StatefulWidget {
  final String? profileId;
  final Map<String, dynamic>? initialData;

  const ProfileEditorScreen({
    super.key,
    this.profileId,
    this.initialData,
  });

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillController = TextEditingController();
  
  List<String> _skills = [];
  List<Map<String, dynamic>> _experience = [];
  List<Map<String, dynamic>> _education = [];
  List<String> _desiredJobTypes = [];
  List<String> _preferredLocations = [];
  String _remotePreference = 'any';
  
  bool _isSaving = false;
  bool get _isEditing => widget.profileId != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    if (widget.initialData != null) {
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    final data = widget.initialData!;
    _nameController.text = data['name'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _skills = List<String>.from(data['skills'] ?? []);
    _experience = List<Map<String, dynamic>>.from(data['experience'] ?? []);
    _education = List<Map<String, dynamic>>.from(data['education'] ?? []);
    _desiredJobTypes = List<String>.from(data['desiredJobTypes'] ?? []);
    _preferredLocations = List<String>.from(data['preferredLocations'] ?? []);
    _remotePreference = data['remotePreference'] ?? 'any';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final profileData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'skills': _skills,
      'experience': _experience,
      'education': _education,
      'desiredJobTypes': _desiredJobTypes,
      'preferredLocations': _preferredLocations,
      'remotePreference': _remotePreference,
    };

    final result = _isEditing
        ? await _profileService.updateProfile(widget.profileId!, profileData)
        : await _profileService.createProfile(profileData);

    setState(() => _isSaving = false);

    if (result['success']) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(_isEditing ? 'Profile updated!' : 'Profile created!'),
            ],
          ),
          backgroundColor: AppColors.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to save profile'),
          backgroundColor: AppColors.accentPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Create Profile'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryPurple,
          labelColor: isDark ? AppColors.primaryPurple : AppColors.primaryPurpleDark,
          unselectedLabelColor: isDark ? AppColors.textSecondary : Colors.grey[600],
          tabs: const [
            Tab(text: 'Basic'),
            Tab(text: 'Skills'),
            Tab(text: 'Experience'),
            Tab(text: 'Preferences'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(isDark),
            _buildSkillsTab(isDark),
            _buildExperienceTab(isDark),
            _buildPreferencesTab(isDark),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: GradientButton(
            text: _isSaving 
                ? 'Saving...' 
                : (_isEditing ? 'Update Profile' : 'Create Profile'),
            onPressed: _isSaving ? () {} : _saveProfile,
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Give your profile a unique name and description',
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Profile Name
          TextFormField(
            controller: _nameController,
            decoration: _buildInputDecoration(
              'Profile Name',
              'e.g., "Frontend Developer Resume"',
              Icons.badge_outlined,
              isDark,
            ),
            style: TextStyle(
              color: isDark ? AppColors.textPrimary : Colors.black87,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a profile name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: _buildInputDecoration(
              'Description',
              'Describe this profile version...',
              Icons.description_outlined,
              isDark,
            ),
            style: TextStyle(
              color: isDark ? AppColors.textPrimary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Skills',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add skills relevant to this profile',
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Add skill input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillController,
                  decoration: _buildInputDecoration(
                    'Add Skill',
                    'e.g., Flutter, React, Python',
                    Icons.code,
                    isDark,
                  ),
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                  onSubmitted: (_) => _addSkill(),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _addSkill,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Skills chips
          if (_skills.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.lightbulb_outline,
                    size: 64,
                    color: isDark ? AppColors.textDisabled : Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No skills added yet',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondary : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills
                  .map((skill) => Chip(
                        label: Text(skill),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _skills.remove(skill);
                          });
                        },
                        backgroundColor: isDark
                            ? AppColors.darkSurfaceVariant
                            : Colors.blue[50],
                        labelStyle: TextStyle(
                          color: isDark ? AppColors.textPrimary : Colors.black87,
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildExperienceTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Work Experience',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your work history',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondary : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _addExperience,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryPurple,
                  side: BorderSide(color: AppColors.primaryPurple),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_experience.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.work_outline,
                    size: 64,
                    color: isDark ? AppColors.textDisabled : Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No experience added yet',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondary : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _experience.length,
              itemBuilder: (context, index) {
                final exp = _experience[index];
                return GradientCard(
                  gradient: isDark ? AppColors.cardGradient : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exp['title'] ?? 'Position',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimary : Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _experience.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exp['company'] ?? 'Company',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.textSecondary : Colors.grey[700],
                        ),
                      ),
                      if (exp['description'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          exp['description'],
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondary : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your job search preferences',
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Remote Preference
          Text(
            'Remote Work',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildPreferenceChip('Any', 'any', isDark),
              _buildPreferenceChip('Remote Only', 'remote_only', isDark),
              _buildPreferenceChip('Hybrid', 'hybrid', isDark),
              _buildPreferenceChip('On-site', 'on_site', isDark),
            ],
          ),
          const SizedBox(height: 32),

          // Desired Job Types
          Text(
            'Job Types',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildJobTypeChip('Full-time', 'full-time', isDark),
              _buildJobTypeChip('Part-time', 'part-time', isDark),
              _buildJobTypeChip('Contract', 'contract', isDark),
              _buildJobTypeChip('Internship', 'internship', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceChip(String label, String value, bool isDark) {
    final isSelected = _remotePreference == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _remotePreference = value;
        });
      },
      selectedColor: AppColors.primaryPurple,
      backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? AppColors.textPrimary : Colors.black87),
      ),
    );
  }

  Widget _buildJobTypeChip(String label, String value, bool isDark) {
    final isSelected = _desiredJobTypes.contains(value);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _desiredJobTypes.add(value);
          } else {
            _desiredJobTypes.remove(value);
          }
        });
      },
      selectedColor: AppColors.primaryPurple,
      checkmarkColor: Colors.white,
      backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? AppColors.textPrimary : Colors.black87),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    String hint,
    IconData icon,
    bool isDark,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: isDark ? AppColors.primaryPurple : AppColors.primaryPurpleDark,
      ),
      labelStyle: TextStyle(
        color: isDark ? AppColors.textSecondary : Colors.grey[700],
      ),
      hintStyle: TextStyle(
        color: isDark ? AppColors.textTertiary : Colors.grey[400],
      ),
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark
              ? AppColors.primaryPurple.withValues(alpha:0.2)
              : Colors.transparent,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.primaryPurple : AppColors.primaryPurpleDark,
          width: 2,
        ),
      ),
    );
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _addExperience() {
    showDialog(
      context: context,
      builder: (context) => _ExperienceDialog(
        onSave: (experience) {
          setState(() {
            _experience.add(experience);
          });
        },
      ),
    );
  }
}

// Experience Dialog
class _ExperienceDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const _ExperienceDialog({required this.onSave});

  @override
  State<_ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<_ExperienceDialog> {
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: const Text('Add Experience'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Job Title',
                hintText: 'e.g., Senior Developer',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company',
                hintText: 'e.g., Google',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _companyController.text.isNotEmpty) {
              widget.onSave({
                'title': _titleController.text,
                'company': _companyController.text,
                'description': _descriptionController.text,
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  bool _isSaving = false;
  
  // Controllers
  final _skillController = TextEditingController();
  List<String> _skills = [];
  
  // Experience
  List<Map<String, dynamic>> _experiences = [];
  
  // Education
  List<Map<String, dynamic>> _education = [];
  
  // Preferences
  String _remotePreference = 'any';
  List<String> _desiredJobTypes = [];
  final _minSalaryController = TextEditingController();
  final _maxSalaryController = TextEditingController();
  final _locationController = TextEditingController();
  List<String> _preferredLocations = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _apiService.get('/profile/job-seeker', withAuth: true);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = data['profile'];
        
        setState(() {
          _skills = List<String>.from(profile['skills'] ?? []);
          _experiences = List<Map<String, dynamic>>.from(profile['experience'] ?? []);
          _education = List<Map<String, dynamic>>.from(profile['education'] ?? []);
          _remotePreference = profile['remotePreference'] ?? 'any';
          _desiredJobTypes = List<String>.from(profile['desiredJobTypes'] ?? []);
          _preferredLocations = List<String>.from(profile['preferredLocations'] ?? []);
          
          if (profile['desiredSalary'] != null) {
            _minSalaryController.text = profile['desiredSalary']['min']?.toString() ?? '';
            _maxSalaryController.text = profile['desiredSalary']['max']?.toString() ?? '';
          }
        });
      }
    } catch (e) {
      // Profile doesn't exist yet, that's okay
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final profileData = {
      'skills': _skills,
      'experience': _experiences,
      'education': _education,
      'desiredJobTypes': _desiredJobTypes,
      'desiredSalary': {
        'min': int.tryParse(_minSalaryController.text) ?? 0,
        'max': int.tryParse(_maxSalaryController.text) ?? 0,
      },
      'preferredLocations': _preferredLocations,
      'remotePreference': _remotePreference,
    };

    try {
      final response = await _apiService.post(
        '/profile/job-seeker',
        profileData,
        withAuth: true,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to save profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _addSkill() {
    if (_skillController.text.isNotEmpty) {
      setState(() {
        _skills.add(_skillController.text.trim());
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
            _experiences.add(experience);
          });
        },
      ),
    );
  }

  void _addEducation() {
    showDialog(
      context: context,
      builder: (context) => _EducationDialog(
        onSave: (edu) {
          setState(() {
            _education.add(edu);
          });
        },
      ),
    );
  }

  void _addLocation() {
    if (_locationController.text.isNotEmpty) {
      setState(() {
        _preferredLocations.add(_locationController.text.trim());
        _locationController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveProfile,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Skills Section
            _buildSectionHeader('Skills'),
            Wrap(
              spacing: 8,
              children: [
                ..._skills.map((skill) => Chip(
                      label: Text(skill),
                      onDeleted: () {
                        setState(() => _skills.remove(skill));
                      },
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      hintText: 'Add a skill',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addSkill,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Experience Section
            _buildSectionHeader('Experience'),
            ..._experiences.asMap().entries.map((entry) {
              final exp = entry.value;
              return Card(
                child: ListTile(
                  title: Text(exp['title'] ?? ''),
                  subtitle: Text(exp['company'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() => _experiences.removeAt(entry.key));
                    },
                  ),
                ),
              );
            }),
            ElevatedButton.icon(
              onPressed: _addExperience,
              icon: const Icon(Icons.add),
              label: const Text('Add Experience'),
            ),
            const SizedBox(height: 24),

            // Education Section
            _buildSectionHeader('Education'),
            ..._education.asMap().entries.map((entry) {
              final edu = entry.value;
              return Card(
                child: ListTile(
                  title: Text(edu['degree'] ?? ''),
                  subtitle: Text(edu['institution'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() => _education.removeAt(entry.key));
                    },
                  ),
                ),
              );
            }),
            ElevatedButton.icon(
              onPressed: _addEducation,
              icon: const Icon(Icons.add),
              label: const Text('Add Education'),
            ),
            const SizedBox(height: 24),

            // Job Preferences
            _buildSectionHeader('Job Preferences'),
            const Text('Desired Job Types:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['full-time', 'part-time', 'contract', 'internship'].map((type) {
                return FilterChip(
                  label: Text(type),
                  selected: _desiredJobTypes.contains(type),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _desiredJobTypes.add(type);
                      } else {
                        _desiredJobTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            const Text('Remote Preference:', style: TextStyle(fontWeight: FontWeight.w500)),
            DropdownButtonFormField<String>(
              value: _remotePreference,
              items: ['remote', 'onsite', 'hybrid', 'any']
                  .map((pref) => DropdownMenuItem(value: pref, child: Text(pref)))
                  .toList(),
              onChanged: (value) {
                setState(() => _remotePreference = value!);
              },
            ),
            const SizedBox(height: 16),

            const Text('Salary Range (USD):', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minSalaryController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxSalaryController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Preferred Locations:', style: TextStyle(fontWeight: FontWeight.w500)),
            Wrap(
              spacing: 8,
              children: _preferredLocations.map((loc) => Chip(
                    label: Text(loc),
                    onDeleted: () {
                      setState(() => _preferredLocations.remove(loc));
                    },
                  )).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'Add location',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addLocation(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addLocation,
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _skillController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _locationController.dispose();
    super.dispose();
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
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Experience'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Job Title'),
            ),
            TextField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_startDate == null ? 'Start Date' : _startDate.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1990),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _startDate = date);
              },
            ),
            ListTile(
              title: Text(_endDate == null ? 'End Date' : _endDate.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1990),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _endDate = date);
              },
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
            widget.onSave({
              'title': _titleController.text,
              'company': _companyController.text,
              'description': _descriptionController.text,
              'startDate': _startDate?.toIso8601String(),
              'endDate': _endDate?.toIso8601String(),
            });
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Education Dialog
class _EducationDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const _EducationDialog({required this.onSave});

  @override
  State<_EducationDialog> createState() => _EducationDialogState();
}

class _EducationDialogState extends State<_EducationDialog> {
  final _degreeController = TextEditingController();
  final _institutionController = TextEditingController();
  final _fieldController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Education'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _degreeController,
            decoration: const InputDecoration(labelText: 'Degree'),
          ),
          TextField(
            controller: _institutionController,
            decoration: const InputDecoration(labelText: 'Institution'),
          ),
          TextField(
            controller: _fieldController,
            decoration: const InputDecoration(labelText: 'Field of Study'),
          ),
          TextField(
            controller: _yearController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Graduation Year'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave({
              'degree': _degreeController.text,
              'institution': _institutionController.text,
              'field': _fieldController.text,
              'graduationYear': int.tryParse(_yearController.text),
            });
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
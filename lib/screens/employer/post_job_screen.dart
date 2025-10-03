import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PostJobScreen extends StatefulWidget {
  final Map<String, dynamic>? job; // For editing existing job

  const PostJobScreen({super.key, this.job});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  bool _isEditing = false;

  // Controllers
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minExpController = TextEditingController();
  final _maxExpController = TextEditingController();
  final _minSalaryController = TextEditingController();
  final _maxSalaryController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _skillController = TextEditingController();

  List<String> _skills = [];
  String _jobType = 'full-time';
  String _remoteType = 'onsite';
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _isEditing = true;
      _loadJobData();
    }
  }

  void _loadJobData() {
    final job = widget.job!;
    _titleController.text = job['title'] ?? '';
    _companyController.text = job['company'] ?? '';
    _descriptionController.text = job['description'] ?? '';
    _jobType = job['jobType'] ?? 'full-time';
    _remoteType = job['remoteType'] ?? 'onsite';
    _status = job['status'] ?? 'active';

    if (job['requirements'] != null) {
      _skills = List<String>.from(job['requirements']['skills'] ?? []);
      if (job['requirements']['experience'] != null) {
        _minExpController.text = job['requirements']['experience']['min']?.toString() ?? '';
        _maxExpController.text = job['requirements']['experience']['max']?.toString() ?? '';
      }
    }

    if (job['salary'] != null) {
      _minSalaryController.text = job['salary']['min']?.toString() ?? '';
      _maxSalaryController.text = job['salary']['max']?.toString() ?? '';
    }

    if (job['location'] != null) {
      _cityController.text = job['location']['city'] ?? '';
      _stateController.text = job['location']['state'] ?? '';
    }
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final jobData = {
      'title': _titleController.text.trim(),
      'company': _companyController.text.trim(),
      'description': _descriptionController.text.trim(),
      'requirements': {
        'skills': _skills,
        'experience': {
          'min': int.tryParse(_minExpController.text) ?? 0,
          'max': int.tryParse(_maxExpController.text) ?? 10,
        },
      },
      'jobType': _jobType,
      'salary': {
        'min': int.tryParse(_minSalaryController.text) ?? 0,
        'max': int.tryParse(_maxSalaryController.text) ?? 0,
        'currency': 'USD',
      },
      'location': {
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'country': 'USA',
      },
      'remoteType': _remoteType,
      'status': _status,
    };

    try {
      final response = _isEditing
          ? await _apiService.put('/jobs/${widget.job!['_id']}', jobData, withAuth: true)
          : await _apiService.post('/jobs', jobData, withAuth: true);

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Job updated successfully!' : 'Job posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to save job');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Job' : 'Post New Job'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveJob,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Job Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Job Description *',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Required Skills',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _skills
                  .map((skill) => Chip(
                        label: Text(skill),
                        onDeleted: () {
                          setState(() => _skills.remove(skill));
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      hintText: 'Add skill',
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
            const Text(
              'Experience Required (years)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minExpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxExpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Salary Range (USD)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
            const SizedBox(height: 24),
            const Text(
              'Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Job Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: ['full-time', 'part-time', 'contract', 'internship']
                  .map((type) => ChoiceChip(
                        label: Text(type),
                        selected: _jobType == type,
                        onSelected: (selected) {
                          setState(() => _jobType = type);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Work Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: ['remote', 'onsite', 'hybrid']
                  .map((type) => ChoiceChip(
                        label: Text(type),
                        selected: _remoteType == type,
                        onSelected: (selected) {
                          setState(() => _remoteType = type);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: ['active', 'closed', 'draft']
                  .map((status) => ChoiceChip(
                        label: Text(status),
                        selected: _status == status,
                        onSelected: (selected) {
                          setState(() => _status = status);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _minExpController.dispose();
    _maxExpController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _skillController.dispose();
    super.dispose();
  }
}
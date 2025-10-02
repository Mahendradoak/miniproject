import 'package:flutter/material.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    
    // TODO: Load from backend
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _projects = [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddProjectDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    return _buildProjectCard(_projects[index], index);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No projects added',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Showcase your work and achievements',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddProjectDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Project'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.folder, color: Colors.purple[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (project['role'] != null)
                        Text(
                          project['role'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditProjectDialog(project, index);
                    } else if (value == 'delete') {
                      _deleteProject(index);
                    }
                  },
                ),
              ],
            ),
            if (project['description'] != null) ...[
              const SizedBox(height: 12),
              Text(
                project['description'],
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
            if (project['technologies'] != null && project['technologies'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (project['technologies'] as List).map((tech) {
                  return Chip(
                    label: Text(
                      tech,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.purple[50],
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  );
                }).toList(),
              ),
            ],
            if (project['link'] != null) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  // TODO: Open link
                },
                child: Row(
                  children: [
                    Icon(Icons.link, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      project['link'],
                      style: TextStyle(
                        color: Colors.blue[700],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddProjectDialog() {
    _showProjectDialog(null, null);
  }

  void _showEditProjectDialog(Map<String, dynamic> project, int index) {
    _showProjectDialog(project, index);
  }

  void _showProjectDialog(Map<String, dynamic>? project, int? index) {
    final nameController = TextEditingController(text: project?['name']);
    final roleController = TextEditingController(text: project?['role']);
    final descriptionController = TextEditingController(text: project?['description']);
    final linkController = TextEditingController(text: project?['link']);
    final techController = TextEditingController();
    List<String> technologies = project?['technologies'] != null 
        ? List<String>.from(project!['technologies'])
        : [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(project == null ? 'Add Project' : 'Edit Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: 'Your Role',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: 'Project Link',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: techController,
                        decoration: const InputDecoration(
                          labelText: 'Technology',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (techController.text.isNotEmpty) {
                          setDialogState(() {
                            technologies.add(techController.text);
                            techController.clear();
                          });
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
                if (technologies.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: technologies.map((tech) {
                      return Chip(
                        label: Text(tech),
                        onDeleted: () {
                          setDialogState(() {
                            technologies.remove(tech);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
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
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Project name is required')),
                  );
                  return;
                }

                final projectData = {
                  'name': nameController.text,
                  'role': roleController.text,
                  'description': descriptionController.text,
                  'link': linkController.text,
                  'technologies': technologies,
                };

                setState(() {
                  if (index == null) {
                    _projects.add(projectData);
                  } else {
                    _projects[index] = projectData;
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(index == null 
                        ? 'Project added successfully' 
                        : 'Project updated successfully'),
                  ),
                );
              },
              child: Text(project == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProject(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
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
      setState(() {
        _projects.removeAt(index);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project deleted')),
        );
      }
    }
  }
}

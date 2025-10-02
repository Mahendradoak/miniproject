import 'package:flutter/material.dart';
import '../../models/job.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'profile_screen.dart';
import '../../widgets/swipeable_job_card.dart';

class SwipeJobsScreen extends StatefulWidget {
  const SwipeJobsScreen({Key? key}) : super(key: key);

  @override
  State<SwipeJobsScreen> createState() => _SwipeJobsScreenState();
}

class _SwipeJobsScreenState extends State<SwipeJobsScreen>
    with SingleTickerProviderStateMixin {
  final JobService _jobService = JobService();
  final AuthService _authService = AuthService();
  
  List<Map<String, dynamic>> _matchingJobs = [];
  List<Job> _allJobs = [];
  List<Job> _currentStack = [];
  
  bool _isLoadingMatches = true;
  bool _isLoadingAll = true;
  bool _showMatches = true;
  
  int _currentIndex = 0;
  late AnimationController _buttonAnimationController;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _loadJobs();
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    await Future.wait([
      _loadMatchingJobs(),
      _loadAllJobs(),
    ]);
    _updateStack();
  }

  Future<void> _loadMatchingJobs() async {
    setState(() => _isLoadingMatches = true);
    
    try {
      final matches = await _jobService.getMatchingJobs();
      setState(() {
        _matchingJobs = matches;
        _isLoadingMatches = false;
      });
    } catch (e) {
      setState(() => _isLoadingMatches = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Complete your profile to see matching jobs'),
            backgroundColor: Colors.orange[700],
            action: SnackBarAction(
              label: 'Profile',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadAllJobs() async {
    setState(() => _isLoadingAll = true);
    
    try {
      final jobs = await _jobService.getAllJobs();
      setState(() {
        _allJobs = jobs;
        _isLoadingAll = false;
      });
    } catch (e) {
      setState(() => _isLoadingAll = false);
    }
  }

  void _updateStack() {
    setState(() {
      if (_showMatches && _matchingJobs.isNotEmpty) {
        _currentStack = _matchingJobs
            .map((match) => match['job'] as Job)
            .toList();
      } else {
        _currentStack = List.from(_allJobs);
      }
      _currentIndex = 0;
    });
  }

  void _handleSwipeLeft() {
    _animateButton(false);
    setState(() {
      _currentIndex++;
    });
    _showFeedback('Skipped', Colors.red, Icons.cancel);
  }

  void _handleSwipeRight() {
    _animateButton(true);
    final currentJob = _currentStack[_currentIndex];
    _showCoverLetterDialog(currentJob);
  }

  void _showCoverLetterDialog(Job job) {
    final coverLetterController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply to ${job.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'At ${job.company}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cover Letter',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: coverLetterController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Write your cover letter here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex++;
              });
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (coverLetterController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please write a cover letter'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _applyToJob(job, coverLetterController.text);
              setState(() {
                _currentIndex++;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Submit Application'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyToJob(Job job, String coverLetter) async {
    try {
      final success = await _jobService.applyToJob(
        jobId: job.id,
        coverLetter: coverLetter,
      );
      
      if (success) {
        _showFeedback('Applied to ${job.title}!', Colors.green, Icons.check_circle);
      } else {
        _showFeedback('Error applying to job', Colors.red, Icons.error);
      }
    } catch (e) {
      _showFeedback('Error applying to job', Colors.red, Icons.error);
    }
  }

  void _animateButton(bool isRight) {
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });
  }

  void _showFeedback(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 800),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showJobDetails(Job job, int? matchScore) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (matchScore != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getMatchColor(matchScore),
                                _getMatchColor(matchScore).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '$matchScore% Match',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.business, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            job.company,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildDetailSection('Job Details', [
                        _buildDetailRow(Icons.location_on, 'Location',
                            job.location?.fullLocation ?? 'Remote'),
                        _buildDetailRow(
                            Icons.work_outline, 'Job Type', job.jobType),
                        _buildDetailRow(
                            Icons.laptop_mac, 'Remote Type', job.remoteType),
                        if (job.salary != null)
                          _buildDetailRow(Icons.attach_money, 'Salary',
                              '\$${job.salary!.min}k - \$${job.salary!.max}k ${job.salary!.currency ?? ""}'),
                      ]),
                      const SizedBox(height: 24),
                      _buildDetailSection('Description', [
                        Text(
                          job.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ]),
                      if (job.requirements?.skills != null &&
                          job.requirements!.skills!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildDetailSection(
                          'Required Skills',
                          [
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: job.requirements!.skills!
                                  .map(
                                    (skill) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue[100]!,
                                        ),
                                      ),
                                      child: Text(
                                        skill,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _handleSwipeLeft();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Colors.red, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showCoverLetterDialog(_currentStack[_currentIndex]);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Apply',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMatchColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  void _logout() async {
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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
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
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _showMatches ? _isLoadingMatches : _isLoadingAll;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Jobs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle between matches and all jobs
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildToggleButton(
                    'Top Matches',
                    Icons.star,
                    _showMatches,
                    () {
                      setState(() {
                        _showMatches = true;
                        _updateStack();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildToggleButton(
                    'All Jobs',
                    Icons.work,
                    !_showMatches,
                    () {
                      setState(() {
                        _showMatches = false;
                        _updateStack();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading jobs...'),
                      ],
                    ),
                  )
                : _currentStack.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No jobs available',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: _loadJobs,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                    : _currentIndex >= _currentStack.length
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 80,
                                  color: Colors.green[400],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No more jobs!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "You've reviewed all available jobs",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: _loadJobs,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Refresh'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              // Show next 2 cards in background for depth
                              if (_currentIndex + 2 < _currentStack.length)
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 32,
                                      right: 32,
                                      top: 16,
                                      bottom: 120,
                                    ),
                                    child: Opacity(
                                      opacity: 0.3,
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (_currentIndex + 1 < _currentStack.length)
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 24,
                                      right: 24,
                                      top: 8,
                                      bottom: 110,
                                    ),
                                    child: Opacity(
                                      opacity: 0.5,
                                      child: Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              // Current card
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom: 100,
                                  ),
                                  child: SwipeableJobCard(
                                    job: _currentStack[_currentIndex],
                                    matchScore: _showMatches && _currentIndex < _matchingJobs.length
                                        ? (_matchingJobs[_currentIndex]['matchScore'] as int)
                                        : null,
                                    onSwipeLeft: _handleSwipeLeft,
                                    onSwipeRight: _handleSwipeRight,
                                    onTap: () => _showJobDetails(
                                      _currentStack[_currentIndex],
                                      _showMatches && _currentIndex < _matchingJobs.length
                                          ? (_matchingJobs[_currentIndex]['matchScore'] as int)
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
          ),

          // Action buttons
          if (!isLoading && _currentIndex < _currentStack.length)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Skip button
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 0.9).animate(
                      CurvedAnimation(
                        parent: _buttonAnimationController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: FloatingActionButton(
                      heroTag: 'skip',
                      onPressed: _handleSwipeLeft,
                      backgroundColor: Colors.red[50],
                      elevation: 2,
                      child: Icon(Icons.close, color: Colors.red[700], size: 32),
                    ),
                  ),

                  // Info button
                  FloatingActionButton(
                    heroTag: 'info',
                    onPressed: () => _showJobDetails(
                      _currentStack[_currentIndex],
                      _showMatches && _currentIndex < _matchingJobs.length
                          ? (_matchingJobs[_currentIndex]['matchScore'] as int)
                          : null,
                    ),
                    backgroundColor: Colors.blue[50],
                    elevation: 2,
                    child: Icon(Icons.info_outline, color: Colors.blue[700], size: 28),
                  ),

                  // Apply button
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 0.9).animate(
                      CurvedAnimation(
                        parent: _buttonAnimationController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: FloatingActionButton(
                      heroTag: 'apply',
                      onPressed: _handleSwipeRight,
                      backgroundColor: Colors.green[50],
                      elevation: 2,
                      child: Icon(Icons.check, color: Colors.green[700], size: 32),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
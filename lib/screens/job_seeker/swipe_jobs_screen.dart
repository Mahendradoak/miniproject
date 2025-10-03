import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_platform_app/providers/theme_provider.dart'; // Adjust package name
import 'package:job_platform_app/utils/responsive.dart'; // Adjust package name
import 'package:job_platform_app/widgets/swipeable_job_card.dart'; // Adjust package name
import 'package:job_platform_app/models/job.dart'; // Adjust package name

class EnhancedSwipeJobsScreen extends StatefulWidget {
  const EnhancedSwipeJobsScreen({super.key});

  @override
  State<EnhancedSwipeJobsScreen> createState() => _EnhancedSwipeJobsScreenState();
}

class _EnhancedSwipeJobsScreenState extends State<EnhancedSwipeJobsScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  // Sample jobs; replace with API data
  final List<Job> _jobs = [
    Job(
      id: '1',
      title: 'Senior Flutter Developer',
      company: 'Google',
      description: 'We are looking for an experienced Flutter developer to join our team and build innovative mobile apps.',
      jobType: 'Full-time',
      remoteType: 'Hybrid',
      location: Location(city: 'Mountain View', state: 'CA'),
      salary: Salary(min: 120, max: 180),
      requirements: JobRequirements(skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs']),
      matchScore: 92,
    ),
    Job(
      id: '2',
      title: 'Machine Learning Engineer',
      company: 'Meta',
      description: 'Join our AI team to build cutting-edge solutions for social platforms.',
      jobType: 'Full-time',
      remoteType: 'Remote',
      location: Location(city: 'Menlo Park', state: 'CA'),
      salary: Salary(min: 140, max: 200),
      requirements: JobRequirements(skills: ['Python', 'TensorFlow', 'PyTorch', 'ML']),
      matchScore: 85,
    ),
    // Add more jobs as needed
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;

    if (_currentIndex >= _jobs.length) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                'No more jobs to show!',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Swipe right to apply to your favorites.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final currentJob = _jobs[_currentIndex];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Swipe Jobs', style: theme.textTheme.headlineLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Text('Dark Mode', style: TextStyle(fontSize: 14)),
                Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                  activeColor: theme.primaryColor,
                  activeTrackColor: theme.primaryColor.withValues(alpha:0.5),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showThemeSettings(context, themeProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = Responsive.isDesktop(context);
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 500 : constraints.maxWidth * 0.9,
                        maxHeight: isDesktop ? 600 : constraints.maxHeight * 0.7,
                      ),
                      child: SwipeableJobCard(
                        key: ValueKey(currentJob.id), // Unique key for rebuilds
                        job: currentJob,
                        matchScore: currentJob.matchScore,
                        onSwipeLeft: () {
                          print('Swiped left (pass) on ${currentJob.title}'); // Debug
                          _nextJob();
                        },
                        onSwipeRight: () {
                          print('Swiped right (like) on ${currentJob.title}'); // Debug
                          _nextJob(); // Or handle application submission
                        },
                        onTap: () {
                          // Navigate to job details
                          _showJobDetails(context, currentJob);
                        },
                      ),
                    ),
                  ),
                ),
                if (!isDesktop) ...[
                  _buildSwipeInstructions(theme),
                ],
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.close, Colors.red, () {
                print('Close button pressed'); // Debug
                _nextJob();
              }, 60),
              _buildActionButton(Icons.star, Colors.blue, () {
                print('Super like button pressed'); // Debug
                _nextJob(); // Handle super like
              }, 50),
              _buildActionButton(Icons.favorite, Colors.green, () {
                print('Like button pressed'); // Debug
                _nextJob(); // Handle like/application
              }, 60),
            ],
          ),
        ),
      ),
    );
  }

  void _nextJob() {
    setState(() {
      if (_currentIndex < _jobs.length - 1) {
        _currentIndex++;
      }
    });
  }

  void _showJobDetails(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(job.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Company: ${job.company}'),
              Text('Location: ${job.location?.fullLocation ?? 'Remote'}'),
              Text('Salary: ${job.salary?.min}k - ${job.salary?.max}k'),
              Text('Description: ${job.description}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildSwipeInstructions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Swipe to match!',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Icon(Icons.swipe_left, color: Colors.red, size: 32),
                  Text('Pass', style: TextStyle(color: Colors.red)),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.swipe_up, color: Colors.blue, size: 32),
                  Text('Super Like', style: TextStyle(color: Colors.blue)),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.swipe_right, color: Colors.green, size: 32),
                  Text('Like', style: TextStyle(color: Colors.green)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed, double size) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha:0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.6),
      ),
    );
  }

  void _showThemeSettings(BuildContext context, ThemeProvider themeProvider) {
    // Same as previous version
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light Mode'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) => themeProvider.setThemeMode(value!),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Mode'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) => themeProvider.setThemeMode(value!),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) => themeProvider.setThemeMode(value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
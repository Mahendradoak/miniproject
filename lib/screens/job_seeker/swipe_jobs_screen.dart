import 'package:flutter/material.dart';

class EnhancedSwipeJobsScreen extends StatefulWidget {
  const EnhancedSwipeJobsScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedSwipeJobsScreen> createState() => _EnhancedSwipeJobsScreenState();
}

class _EnhancedSwipeJobsScreenState extends State<EnhancedSwipeJobsScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isDarkMode = false;
  late AnimationController _cardAnimationController;
  late AnimationController _matchAnimationController;
  Offset _dragOffset = Offset.zero;
  
  // Sample job data (replace with your API call)
  final List<Map<String, dynamic>> _jobs = [
    {
      'title': 'Senior Flutter Developer',
      'company': 'Google',
      'location': 'Mountain View, CA',
      'salary': '\$120k - \$180k',
      'type': 'Full-time',
      'remote': 'Hybrid',
      'matchScore': 92,
      'skills': ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
      'description': 'We are looking for an experienced Flutter developer...',
      'posted': '2 days ago',
    },
    {
      'title': 'Machine Learning Engineer',
      'company': 'Meta',
      'location': 'Menlo Park, CA',
      'salary': '\$140k - \$200k',
      'type': 'Full-time',
      'remote': 'Remote',
      'matchScore': 85,
      'skills': ['Python', 'TensorFlow', 'PyTorch', 'ML'],
      'description': 'Join our AI team to build cutting-edge solutions...',
      'posted': '1 day ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _matchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _matchAnimationController.dispose();
    super.dispose();
  }

  Color _getMatchColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.lightGreen;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getMatchLabel(int score) {
    if (score >= 90) return 'Excellent Match';
    if (score >= 75) return 'Great Match';
    if (score >= 60) return 'Good Match';
    return 'Fair Match';
  }

  void _handleSwipe(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _handleSwipeEnd(DragEndDetails details) {
    if (_dragOffset.dx.abs() > 100) {
      if (_dragOffset.dx > 0) {
        _onLike();
      } else {
        _onDislike();
      }
    }
    setState(() {
      _dragOffset = Offset.zero;
    });
  }

  void _onLike() {
    setState(() {
      if (_currentIndex < _jobs.length - 1) {
        _currentIndex++;
      }
    });
  }

  void _onDislike() {
    setState(() {
      if (_currentIndex < _jobs.length - 1) {
        _currentIndex++;
      }
    });
  }

  void _onSuperLike() {
    // Handle super like
    setState(() {
      if (_currentIndex < _jobs.length - 1) {
        _currentIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    
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
                'No more jobs to show',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
        ),
      );
    }

    final currentJob = _jobs[_currentIndex];
    final matchScore = currentJob['matchScore'] as int;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        title: Text('Discover Jobs', style: TextStyle(color: textColor)),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: textColor),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Match percentage badge at top
            Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: _matchAnimationController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getMatchColor(matchScore),
                          _getMatchColor(matchScore).withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: _getMatchColor(matchScore).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: _matchAnimationController.value * 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '$matchScore% ${_getMatchLabel(matchScore)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Job card stack
            Expanded(
              child: Stack(
                children: [
                  // Next card (preview)
                  if (_currentIndex + 1 < _jobs.length)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Transform.scale(
                          scale: 0.95,
                          child: _buildJobCard(_jobs[_currentIndex + 1], cardColor, textColor, isDark),
                        ),
                      ),
                    ),
                  
                  // Current card (swipeable)
                  Positioned.fill(
                    child: GestureDetector(
                      onPanUpdate: _handleSwipe,
                      onPanEnd: _handleSwipeEnd,
                      child: Transform.translate(
                        offset: _dragOffset,
                        child: Transform.rotate(
                          angle: _dragOffset.dx / 1000,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildJobCard(currentJob, cardColor, textColor, isDark),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Swipe indicators
                  if (_dragOffset.dx.abs() > 50)
                    Positioned(
                      top: 100,
                      left: _dragOffset.dx > 0 ? null : 50,
                      right: _dragOffset.dx > 0 ? 50 : null,
                      child: Transform.rotate(
                        angle: _dragOffset.dx > 0 ? -0.3 : 0.3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _dragOffset.dx > 0 ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: Text(
                            _dragOffset.dx > 0 ? 'LIKE' : 'NOPE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    Icons.close,
                    Colors.red,
                    _onDislike,
                    60,
                  ),
                  _buildActionButton(
                    Icons.star,
                    Colors.blue,
                    _onSuperLike,
                    70,
                  ),
                  _buildActionButton(
                    Icons.favorite,
                    Colors.green,
                    _onLike,
                    60,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, Color cardColor, Color textColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company header with gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [Colors.blue[900]!, Colors.blue[700]!]
                        : [Colors.blue[700]!, Colors.blue[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          job['company'][0],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['company'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            job['posted'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Job details
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'],
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(job['location'], style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(job['salary'], style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.work, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text('${job['type']} • ${job['remote']}', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job['description'],
                      style: TextStyle(color: textColor.withOpacity(0.7), height: 1.5),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Required Skills',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (job['skills'] as List).map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(icon, color: color, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/job.dart';

class SwipeableJobCard extends StatefulWidget {
  final Job job;
  final int? matchScore;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onTap;

  const SwipeableJobCard({
    Key? key,
    required this.job,
    this.matchScore,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onTap,
  }) : super(key: key);

  @override
  State<SwipeableJobCard> createState() => _SwipeableJobCardState();
}

class _SwipeableJobCardState extends State<SwipeableJobCard>
    with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;
  bool _isDragging = false;
  double _angle = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
      _angle = 25 * _position.dx / MediaQuery.of(context).size.width;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    if (_position.dx.abs() > threshold) {
      // Swipe completed
      final direction = _position.dx > 0 ? 1 : -1;
      _animateCardOff(direction);
    } else {
      // Return to center
      _resetPosition();
    }
  }

  void _animateCardOff(int direction) {
    final screenWidth = MediaQuery.of(context).size.width;
    final endX = screenWidth * 1.5 * direction;
    
    final animation = Tween<Offset>(
      begin: _position,
      end: Offset(endX, _position.dy * 2),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    animation.addListener(() {
      setState(() {
        _position = animation.value;
        _angle = 25 * animation.value.dx / screenWidth;
      });
    });

    _animationController.forward().then((_) {
      _animationController.reset();
      if (direction > 0) {
        widget.onSwipeRight();
      } else {
        widget.onSwipeLeft();
      }
      setState(() {
        _position = Offset.zero;
        _angle = 0;
      });
    });
  }

  void _resetPosition() {
    final animation = Tween<Offset>(
      begin: _position,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    final angleAnimation = Tween<double>(
      begin: _angle,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    animation.addListener(() {
      setState(() {
        _position = animation.value;
        _angle = angleAnimation.value;
      });
    });

    _animationController.forward().then((_) {
      _animationController.reset();
    });
  }

  Color _getMatchColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final opacity = min(1.0, _position.dx.abs() / (screenWidth * 0.3));

    return Stack(
      children: [
        // Background indicators
        if (_position.dx.abs() > 20)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 50),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: _position.dx > 0
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _position.dx > 0
                            ? Colors.green.withOpacity(0.9)
                            : Colors.red.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _position.dx > 0
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Main card
        Transform.translate(
          offset: _position,
          child: Transform.rotate(
            angle: _angle * pi / 180,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              onTap: widget.onTap,
              child: Card(
                elevation: _isDragging ? 12 : 6,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 450,
                    maxHeight: 550,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: widget.matchScore != null && widget.matchScore! >= 80
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.green.withOpacity(0.05),
                            ],
                          )
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Content
                        SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Match score badge
                                if (widget.matchScore != null)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _getMatchColor(widget.matchScore!),
                                            _getMatchColor(widget.matchScore!)
                                                .withOpacity(0.8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _getMatchColor(widget.matchScore!)
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${widget.matchScore}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          const Text(
                                            'Match',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                // Job title
                                Text(
                                  widget.job.title,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                // Company
                                Row(
                                  children: [
                                    Icon(
                                      Icons.business,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.job.company,
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Info chips
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _buildInfoChip(
                                      Icons.location_on,
                                      widget.job.location?.fullLocation ?? 'Remote',
                                      Colors.blue,
                                    ),
                                    _buildInfoChip(
                                      Icons.work_outline,
                                      widget.job.jobType,
                                      Colors.green,
                                    ),
                                    _buildInfoChip(
                                      Icons.laptop_mac,
                                      widget.job.remoteType,
                                      Colors.purple,
                                    ),
                                  ],
                                ),
                                if (widget.job.salary != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.green[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.attach_money,
                                          size: 18,
                                          color: Colors.green[700],
                                        ),
                                        Text(
                                          '${widget.job.salary!.min}k - ${widget.job.salary!.max}k ${widget.job.salary!.currency ?? ""}',
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                // Description
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.job.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.job.requirements?.skills != null &&
                                    widget.job.requirements!.skills!.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Required Skills',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: widget.job.requirements!.skills!
                                        .take(6)
                                        .map(
                                          (skill) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.blue[100]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              skill,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.blue[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  if (widget.job.requirements!.skills!.length > 6)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        '+${widget.job.requirements!.skills!.length - 6} more skills',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                                const SizedBox(height: 24),
                                // Swipe hint
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.swipe_left, color: Colors.grey[400]),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Swipe or use buttons below',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[500],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.swipe_right, color: Colors.grey[400]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
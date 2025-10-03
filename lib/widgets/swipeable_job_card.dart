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
    super.key,
    required this.job,
    this.matchScore,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onTap,
  });

  @override
  State<SwipeableJobCard> createState() => _SwipeableJobCardState();
}

class _SwipeableJobCardState extends State<SwipeableJobCard> with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;
  double _angle = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    // Pan started
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
      _angle = 25 * _position.dx / MediaQuery.of(context).size.width;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    if (_position.dx.abs() > threshold) {
      final direction = _position.dx > 0 ? 1 : -1;
      _animateCardOff(direction);
    } else {
      _resetPosition();
    }
  }

  void _animateCardOff(int direction) {
    final screenWidth = MediaQuery.of(context).size.width;
    final endX = screenWidth * 1.5 * direction;
    final animation = Tween<Offset>(
      begin: _position,
      end: Offset(endX, _position.dy * 2),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    animation.addListener(() {
      setState(() {
        _position = animation.value;
        _angle = 25 * animation.value.dx / screenWidth;
      });
    });

    _animationController.forward().then((_) {
      _animationController.reset();
      direction > 0 ? widget.onSwipeRight() : widget.onSwipeLeft();
      setState(() {
        _position = Offset.zero;
        _angle = 0;
      });
    });
  }

  void _resetPosition() {
    final animation = Tween<Offset>(begin: _position, end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    final angleAnimation = Tween<double>(begin: _angle, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    animation.addListener(() {
      setState(() {
        _position = animation.value;
        _angle = angleAnimation.value;
      });
    });

    _animationController.forward().then((_) => _animationController.reset());
  }

  Color _getMatchColor(int score, Brightness brightness) {
    final baseColor = score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red;
    return brightness == Brightness.dark ? baseColor.shade300 : baseColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final screenWidth = MediaQuery.of(context).size.width;
    final opacity = min(1.0, _position.dx.abs() / (screenWidth * 0.3));

    return Semantics(
      label: 'Swipeable job card for ${widget.job.title}',
      child: Stack(
        children: [
          if (_position.dx.abs() > 20)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(milliseconds: 50),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: _position.dx > 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _position.dx > 0 ? Colors.green.withValues(alpha:0.9) : Colors.red.withValues(alpha:0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _position.dx > 0 ? Icons.check_circle : Icons.cancel,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: theme.cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.job.title,
                                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 20),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.matchScore != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getMatchColor(widget.matchScore!, brightness),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${widget.matchScore}% Match',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.job.company,
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.job.description,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInfoChip(Icons.location_on, widget.job.location?.fullLocation ?? 'Unknown', Colors.blue, theme),
                            _buildInfoChip(Icons.work, widget.job.jobType, Colors.green, theme),
                            _buildInfoChip(Icons.laptop_mac, widget.job.remoteType, Colors.purple, theme),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Required Skills',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.job.requirements!.skills!
                              .take(6)
                              .map(
                                (skill) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50]?.withValues(alpha:brightness == Brightness.dark ? 0.2 : 1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue[100]!),
                                  ),
                                  child: Text(
                                    skill,
                                    style: TextStyle(fontSize: 13, color: Colors.blue[700], fontWeight: FontWeight.w500),
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
                              style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.6), fontStyle: FontStyle.italic),
                            ),
                          ),
                        const SizedBox(height: 24),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.swipe_left, color: theme.iconTheme.color?.withValues(alpha:0.4)),
                              const SizedBox(width: 8),
                              Text(
                                'Swipe or use buttons below',
                                style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.5), fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.swipe_right, color: theme.iconTheme.color?.withValues(alpha:0.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
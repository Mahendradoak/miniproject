import 'package:flutter/material.dart';
import '../models/job.dart';
import '../utils/responsive.dart';


class JobCard extends StatelessWidget {
  final Job job;
  final int? matchScore;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.job,
    this.matchScore,
    required this.onTap,
  });

  Color _getMatchColor(int score, Brightness brightness) {
    final baseColor = score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red;
    return brightness == Brightness.dark ? baseColor.shade300 : baseColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final cardPadding = Responsive.isDesktop(context) ? 24.0 : 16.0;

    return Semantics(
      label: 'Job card for ${job.title} at ${job.company}',
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: cardPadding / 2, vertical: 8),
        elevation: 3,
        shadowColor: theme.shadowColor.withValues(alpha:0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.cardColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: matchScore != null && matchScore! >= 80
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [theme.cardColor, _getMatchColor(matchScore!, brightness).withValues(alpha:0.05)],
                    )
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 18),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.business, size: 14, color: theme.iconTheme.color?.withValues(alpha:0.6)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    job.company,
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (matchScore != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getMatchColor(matchScore!, brightness),
                                _getMatchColor(matchScore!, brightness).withValues(alpha:0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _getMatchColor(matchScore!, brightness).withValues(alpha:0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$matchScore%',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const Text(
                                'Match',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.location_on, job.location?.fullLocation ?? 'Unknown', Colors.blue, theme),
                      _buildInfoChip(Icons.work, job.jobType, Colors.green, theme),
                      _buildInfoChip(Icons.laptop_mac, job.remoteType, Colors.purple, theme),
                    ],
                  ),
                  if (job.salary != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[50]?.withValues(alpha:brightness == Brightness.dark ? 0.2 : 1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                          Text(
                            '${job.salary!.min}k - ${job.salary!.max}k ${job.salary!.currency ?? ""}',
                            style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (job.requirements?.skills != null && job.requirements!.skills!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: job.requirements!.skills!
                          .take(4)
                          .map((skill) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50]?.withValues(alpha:brightness == Brightness.dark ? 0.2 : 1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue[100]!),
                                ),
                                child: Text(
                                  skill,
                                  style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w500),
                                ),
                              ))
                          .toList(),
                    ),
                    if (job.requirements!.skills!.length > 4)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '+${job.requirements!.skills!.length - 4} more skills',
                          style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.6), fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tap to view details',
                        style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.5), fontStyle: FontStyle.italic),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: theme.iconTheme.color?.withValues(alpha:0.4)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
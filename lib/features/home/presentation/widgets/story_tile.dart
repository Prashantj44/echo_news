import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/story.dart';

class StoryTile extends StatelessWidget {
  final Story story;
  final int index;

  const StoryTile({super.key, required this.story, required this.index});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat.yMMMd().add_jm().format(
      DateTime.fromMillisecondsSinceEpoch(story.time * 1000),
    );

    // Deterministic brand colors for popular publishers to create a curated feel
    final sourceColor = _getSourceColor(story.by);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.slateDark.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(context, AppRouter.detail, arguments: story);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Dynamic brand badge for the news source
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sourceColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: sourceColor.withValues(alpha: 0.24), width: 1),
                      ),
                      child: Text(
                        story.by.toUpperCase(),
                        style: TextStyle(
                          color: sourceColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Relative/formatted time text
                    Expanded(
                      child: Text(
                        timeStr,
                        style: const TextStyle(
                          color: AppColors.slate500,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Story Title
                Text(
                  story.title,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slateDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Trending indicator
                    const Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.accentTeal,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${story.score} views',
                      style: const TextStyle(
                        color: AppColors.accentTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // AI discussion trigger
                    const Icon(
                      Icons.insights_rounded,
                      color: AppColors.primaryIndigo,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Debate (${story.descendants})',
                      style: const TextStyle(
                        color: AppColors.primaryIndigo,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Bookmark button
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bookmarked!'),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.bookmark_border_rounded, color: AppColors.slate400, size: 20),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Share button
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share link copied!'),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.share_outlined, color: AppColors.slate400, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Generates deterministic brand colors for consistent editorial design
  Color _getSourceColor(String source) {
    final lower = source.toLowerCase();
    if (lower.contains('google')) return const Color(0xFF4285F4);
    if (lower.contains('techcrunch') || lower.contains('tech')) return const Color(0xFF02C39A);
    if (lower.contains('bbc')) return const Color(0xFFB00020);
    if (lower.contains('cnn')) return const Color(0xFFCC0000);
    if (lower.contains('bloomberg') || lower.contains('business')) return const Color(0xFF3B82F6);
    if (lower.contains('reuters')) return AppColors.warning;
    if (lower.contains('nytimes') || lower.contains('york')) return AppColors.slate800;
    if (lower.contains('guardian')) return const Color(0xFF059669);
    
    // Fallback: Pick a color based on the hash of the source name
    final colors = [
      AppColors.primaryIndigo,
      AppColors.accentTeal,
      AppColors.categoryCyan,
      AppColors.categoryBlue,
      const Color(0xFF7C3AED),
      AppColors.categoryPink,
      AppColors.categoryOrange,
    ];
    final hash = source.hashCode.abs();
    return colors[hash % colors.length];
  }
}

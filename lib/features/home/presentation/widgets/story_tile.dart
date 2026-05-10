import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/story.dart';
import '../../../detail/presentation/pages/detail_page.dart';

class StoryTile extends StatelessWidget {
  final Story story;
  final int index;

  const StoryTile({super.key, required this.story, required this.index});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat.yMMMd().add_jm().format(
      DateTime.fromMillisecondsSinceEpoch(story.time * 1000),
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(story: story),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '$index.',
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_up, color: Colors.grey, size: 24),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${story.score} points by ${story.by} | $timeStr | ${story.descendants} comments',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

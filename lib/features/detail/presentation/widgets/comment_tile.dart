import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/comment.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final double depth;

  const CommentTile({super.key, required this.comment, this.depth = 0});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat.yMMMd().add_jm().format(
      DateTime.fromMillisecondsSinceEpoch(comment.time * 1000),
    );

    return Padding(
      padding: EdgeInsets.only(left: 12.0 * depth + 8.0, top: 12.0, right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_drop_up, color: Colors.grey, size: 18),
              const SizedBox(width: 4),
              Text(
                '${comment.by} | $timeStr',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Html(
              data: comment.text,
              onLinkTap: (url, _, __) async {
                if (url != null) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              style: {
                "body": Style(
                  fontSize: FontSize(14.0),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  color: Colors.black87,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

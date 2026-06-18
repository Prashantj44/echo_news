import '../models/story_model.dart';

class RssParser {
  static List<StoryModel> parseGoogleNewsRss(String xmlString) {
    final List<StoryModel> stories = [];
    final RegExp itemRegex = RegExp(r'<item>([\s\S]*?)</item>');
    final RegExp titleRegex = RegExp(r'<title>([\s\S]*?)</title>');
    final RegExp linkRegex = RegExp(r'<link>([\s\S]*?)</link>');
    final RegExp pubDateRegex = RegExp(r'<pubDate>([\s\S]*?)</pubDate>');
    final RegExp sourceRegex = RegExp(r'<source[^>]*>([\s\S]*?)</source>');

    final matches = itemRegex.allMatches(xmlString);
    int index = 1;

    for (var match in matches) {
      final itemContent = match.group(1) ?? '';

      final titleMatch = titleRegex.firstMatch(itemContent);
      final linkMatch = linkRegex.firstMatch(itemContent);
      final pubDateMatch = pubDateRegex.firstMatch(itemContent);
      final sourceMatch = sourceRegex.firstMatch(itemContent);

      var title = titleMatch?.group(1) ?? 'Untitled Story';
      title = _cleanXmlText(title);

      var url = linkMatch?.group(1) ?? '';
      url = _cleanXmlText(url);

      var pubDate = pubDateMatch?.group(1) ?? '';
      pubDate = _cleanXmlText(pubDate);

      var source = sourceMatch?.group(1) ?? 'Unknown Source';
      source = _cleanXmlText(source);

      // Clean publisher from title if title ends with " - Publisher"
      if (source != 'Unknown Source') {
        final suffix = ' - $source';
        if (title.endsWith(suffix)) {
          title = title.substring(0, title.length - suffix.length).trim();
        } else if (title.contains(' - ')) {
          // If title has a " - " near the end, check if it's the publisher
          final lastIndex = title.lastIndexOf(' - ');
          if (lastIndex > title.length - 40) {
            title = title.substring(0, lastIndex).trim();
          }
        }
      } else if (title.contains(' - ')) {
        final lastIndex = title.lastIndexOf(' - ');
        if (lastIndex > title.length - 40) {
          source = title.substring(lastIndex + 3).trim();
          title = title.substring(0, lastIndex).trim();
        }
      }

      // Parse date
      DateTime dateTime;
      try {
        dateTime = _parseRfc2822(pubDate);
      } catch (_) {
        dateTime = DateTime.now().subtract(Duration(minutes: index * 15));
      }

      final timeInSeconds = dateTime.millisecondsSinceEpoch ~/ 1000;
      final score = 80 + (matches.length - index) * 5 + (index % 4 == 0 ? 25 : 0);
      final descendants = index % 3 == 0 ? 0 : 4 + (index % 5) * 2;

      stories.add(
        StoryModel(
          id: url.hashCode,
          title: title,
          url: url,
          by: source,
          score: score,
          time: timeInSeconds,
          kids: List.generate(descendants, (i) => url.hashCode + i + 1),
          descendants: descendants,
        ),
      );
      index++;
    }
    return stories;
  }

  static String _cleanXmlText(String text) {
    var cleaned = text
        .replaceAll('<![CDATA[', '')
        .replaceAll(']]>', '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
    return cleaned;
  }

  static DateTime _parseRfc2822(String dateStr) {
    try {
      var cleaned = dateStr;
      if (cleaned.contains(',')) {
        cleaned = cleaned.split(',').last.trim();
      }

      cleaned = cleaned.replaceAll('GMT', '').replaceAll('UTC', '').trim();

      final parts = cleaned.split(RegExp(r'\s+'));
      if (parts.length >= 4) {
        final day = int.parse(parts[0]);
        final monthStr = parts[1].toLowerCase();
        final year = int.parse(parts[2]);

        final timeParts = parts[3].split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;

        final months = [
          'jan',
          'feb',
          'mar',
          'apr',
          'may',
          'jun',
          'jul',
          'aug',
          'sep',
          'oct',
          'nov',
          'dec'
        ];
        final month = months.indexOf(monthStr.substring(0, 3)) + 1;

        return DateTime.utc(year, month, day, hour, minute, second).toLocal();
      }
    } catch (_) {}
    return DateTime.now();
  }
}

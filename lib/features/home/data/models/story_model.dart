import '../../domain/entities/story.dart';

class StoryModel extends Story {
  const StoryModel({
    required super.id,
    required super.title,
    super.url,
    required super.by,
    required super.score,
    required super.time,
    super.kids,
    required super.descendants,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'],
      title: json['title'] ?? '',
      url: json['url'],
      by: json['by'] ?? 'unknown',
      score: json['score'] ?? 0,
      time: json['time'] ?? 0,
      kids: json['kids'] != null ? List<int>.from(json['kids']) : null,
      descendants: json['descendants'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'by': by,
      'score': score,
      'time': time,
      'kids': kids,
      'descendants': descendants,
    };
  }
}

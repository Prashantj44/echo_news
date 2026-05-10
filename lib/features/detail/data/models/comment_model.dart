import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.by,
    required super.text,
    required super.time,
    super.kids,
    super.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      by: json['by'] ?? 'unknown',
      text: json['text'] ?? '',
      time: json['time'] ?? 0,
      kids: json['kids'] != null ? List<int>.from(json['kids']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'by': by,
      'text': text,
      'time': time,
      'kids': kids,
    };
  }
}

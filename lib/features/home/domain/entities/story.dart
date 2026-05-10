import 'package:equatable/equatable.dart';

class Story extends Equatable {
  final int id;
  final String title;
  final String? url;
  final String by;
  final int score;
  final int time;
  final List<int>? kids;
  final int descendants;

  const Story({
    required this.id,
    required this.title,
    this.url,
    required this.by,
    required this.score,
    required this.time,
    this.kids,
    required this.descendants,
  });

  @override
  List<Object?> get props => [id, title, url, by, score, time, kids, descendants];
}

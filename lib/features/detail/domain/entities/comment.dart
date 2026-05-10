import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final int id;
  final String by;
  final String text;
  final int time;
  final List<int>? kids;
  final List<Comment>? replies;

  const Comment({
    required this.id,
    required this.by,
    required this.text,
    required this.time,
    this.kids,
    this.replies,
  });

  @override
  List<Object?> get props => [id, by, text, time, kids, replies];
}

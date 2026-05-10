import 'package:equatable/equatable.dart';

abstract class DetailEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchComments extends DetailEvent {
  final List<int> commentIds;
  FetchComments({required this.commentIds});
  @override
  List<Object> get props => [commentIds];
}

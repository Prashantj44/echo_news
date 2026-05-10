import 'package:equatable/equatable.dart';
import '../../domain/entities/comment.dart';

abstract class DetailState extends Equatable {
  @override
  List<Object> get props => [];
}

class DetailInitial extends DetailState {}
class DetailLoading extends DetailState {}
class DetailLoaded extends DetailState {
  final List<Comment> comments;
  DetailLoaded({required this.comments});
  @override
  List<Object> get props => [comments];
}
class DetailError extends DetailState {
  final String message;
  DetailError({required this.message});
  @override
  List<Object> get props => [message];
}

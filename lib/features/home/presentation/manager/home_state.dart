import 'package:equatable/equatable.dart';
import '../../domain/entities/story.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final List<Story> stories;
  HomeLoaded({required this.stories});
  @override
  List<Object> get props => [stories];
}
class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
  @override
  List<Object> get props => [message];
}

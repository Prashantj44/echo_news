import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchTopStories extends HomeEvent {
  final String category;
  final String countryCode;
  final String languageCode;

  FetchTopStories({
    this.category = 'headlines',
    this.countryCode = 'US',
    this.languageCode = 'en',
  });

  @override
  List<Object> get props => [category, countryCode, languageCode];
}

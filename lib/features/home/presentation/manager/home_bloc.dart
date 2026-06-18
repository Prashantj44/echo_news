import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_top_stories.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetTopStories getTopStories;

  HomeBloc({required this.getTopStories}) : super(HomeInitial()) {
    on<FetchTopStories>((event, emit) async {
      emit(HomeLoading());
      final result = await getTopStories(
        FetchNewsParams(
          category: event.category,
          countryCode: event.countryCode,
          languageCode: event.languageCode,
        ),
      );
      result.fold(
        (failure) => emit(HomeError(message: 'Failed to fetch stories')),
        (stories) => emit(HomeLoaded(stories: stories)),
      );
    });
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_comments.dart';
import 'detail_event.dart';
import 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  final GetComments getComments;

  DetailBloc({required this.getComments}) : super(DetailInitial()) {
    on<FetchComments>((event, emit) async {
      if (event.commentIds.isEmpty) {
        emit(DetailLoaded(comments: const []));
        return;
      }
      emit(DetailLoading());
      final result = await getComments(event.commentIds);
      result.fold(
        (failure) => emit(DetailError(message: 'Failed to fetch comments')),
        (comments) => emit(DetailLoaded(comments: comments)),
      );
    });
  }
}

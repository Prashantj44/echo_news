import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/story.dart';
import '../repositories/home_repository.dart';

class GetTopStories implements UseCase<List<Story>, FetchNewsParams> {
  final HomeRepository repository;

  GetTopStories(this.repository);

  @override
  Future<Either<Failure, List<Story>>> call(FetchNewsParams params) async {
    return await repository.getNewsStories(
      category: params.category,
      countryCode: params.countryCode,
      languageCode: params.languageCode,
    );
  }
}

class FetchNewsParams extends Equatable {
  final String category;
  final String countryCode;
  final String languageCode;

  const FetchNewsParams({
    required this.category,
    required this.countryCode,
    required this.languageCode,
  });

  @override
  List<Object?> get props => [category, countryCode, languageCode];
}

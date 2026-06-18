import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Story>>> getNewsStories({
    required String category,
    required String countryCode,
    required String languageCode,
  }) async {
    try {
      final remoteStories = await remoteDataSource.getNewsStories(
        category: category,
        countryCode: countryCode,
        languageCode: languageCode,
      );
      return Right(remoteStories);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

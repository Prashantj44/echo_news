import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/detail_repository.dart';
import '../datasources/detail_remote_data_source.dart';

class DetailRepositoryImpl implements DetailRepository {
  final DetailRemoteDataSource remoteDataSource;

  DetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Comment>>> getComments(List<int> commentIds) async {
    try {
      final remoteComments = await remoteDataSource.getComments(commentIds);
      return Right(remoteComments);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

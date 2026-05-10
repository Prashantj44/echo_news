import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment.dart';
import '../repositories/detail_repository.dart';

class GetComments implements UseCase<List<Comment>, List<int>> {
  final DetailRepository repository;

  GetComments(this.repository);

  @override
  Future<Either<Failure, List<Comment>>> call(List<int> params) async {
    return await repository.getComments(params);
  }
}

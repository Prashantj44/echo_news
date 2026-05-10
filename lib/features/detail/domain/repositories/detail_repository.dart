import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/comment.dart';

abstract class DetailRepository {
  Future<Either<Failure, List<Comment>>> getComments(List<int> commentIds);
}

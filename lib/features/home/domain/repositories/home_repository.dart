import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/story.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<Story>>> getTopStories();
}

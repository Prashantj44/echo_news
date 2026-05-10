import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/story.dart';
import '../repositories/home_repository.dart';

class GetTopStories implements UseCase<List<Story>, NoParams> {
  final HomeRepository repository;

  GetTopStories(this.repository);

  @override
  Future<Either<Failure, List<Story>>> call(NoParams params) async {
    return await repository.getTopStories();
  }
}

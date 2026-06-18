import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'features/home/data/datasources/home_remote_data_source.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_top_stories.dart';
import 'features/home/presentation/manager/home_bloc.dart';
import 'features/detail/data/datasources/detail_remote_data_source.dart';
import 'features/detail/data/repositories/detail_repository_impl.dart';
import 'features/detail/domain/repositories/detail_repository.dart';
import 'features/detail/domain/usecases/get_comments.dart';
import 'features/detail/presentation/manager/detail_bloc.dart';

import 'features/home/data/datasources/gemini_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Core Services
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => FirestoreService());
  sl.registerLazySingleton(() => GeminiService(client: sl()));

  //! Features - Home
  // Bloc
  sl.registerFactory(() => HomeBloc(getTopStories: sl()));
  // Use cases
  sl.registerLazySingleton(() => GetTopStories(sl()));
  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(client: sl()),
  );

  //! Features - Detail
  // Bloc
  sl.registerFactory(() => DetailBloc(getComments: sl()));
  // Use cases
  sl.registerLazySingleton(() => GetComments(sl()));
  // Repository
  sl.registerLazySingleton<DetailRepository>(
    () => DetailRepositoryImpl(remoteDataSource: sl()),
  );
  // Data sources
  sl.registerLazySingleton<DetailRemoteDataSource>(
    () => DetailRemoteDataSourceImpl(client: sl()),
  );

  //! External
  sl.registerLazySingleton(() => http.Client());
}

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:meme_editor/features/editor/data/datasources/local/local_data_source.dart';
import 'package:meme_editor/features/editor/data/datasources/remote/remote_data_source.dart';
import 'package:meme_editor/features/editor/data/repositories/meme_repository_impl.dart';
import 'package:meme_editor/features/editor/domain/entities/meme.dart';
import 'package:meme_editor/features/editor/domain/repositories/meme_repository.dart';
import 'package:meme_editor/features/editor/domain/usecases/get_templates_usecase.dart';

final sl = GetIt.instance;

class Injection {
  static Future<void> init(Box<Meme> memeBox) async {
    // ✅ Core Dependencies
    sl.registerLazySingleton<Dio>(() => Dio());
    sl.registerSingleton<Box<Meme>>(memeBox);

    // ✅ Data Sources
    sl.registerLazySingleton<RemoteDataSource>(
      () => RemoteDataSourceImpl(sl<Dio>()),
    );

    sl.registerLazySingleton<LocalDataSource>(
      () => LocalDataSourceImpl(sl<Box<Meme>>()),
    );

    sl.registerLazySingleton<GetTemplatesUsecase>(
      () => GetTemplatesUsecase(sl<MemeRepository>()),
    );

    // ✅ Repositories
    sl.registerLazySingleton<MemeRepository>(
      () => MemeRepositoryImpl(
        remote: sl<RemoteDataSource>(),
        local: sl<LocalDataSource>(),
      ),
    );
  }
}

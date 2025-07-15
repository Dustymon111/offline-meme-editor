import '../entities/meme_template.dart';
import '../repositories/meme_repository.dart';

class GetTemplatesUsecase {
  final MemeRepository repository;

  GetTemplatesUsecase(this.repository);

  Future<List<MemeTemplate>> call() async {
    return await repository.getTemplates();
  }
}

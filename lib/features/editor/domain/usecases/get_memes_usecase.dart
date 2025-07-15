import '../entities/meme.dart';
import '../repositories/meme_repository.dart';

class GetMemesUseCase {
  final MemeRepository repository;

  GetMemesUseCase(this.repository);

  Future<List<Meme>> call() async {
    return await repository.getAllMemes();
  }
}

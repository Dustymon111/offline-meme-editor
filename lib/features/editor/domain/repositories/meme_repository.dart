import 'package:meme_editor/features/editor/domain/entities/meme.dart';
import 'package:meme_editor/features/editor/domain/entities/meme_template.dart';

abstract class MemeRepository {
  Future<List<Meme>> getAllMemes();
  Future<List<MemeTemplate>> getTemplates();
}

import 'package:dio/dio.dart';
import 'package:meme_editor/features/editor/domain/entities/meme_template.dart';

/// Abstract interface
abstract class RemoteDataSource {
  Future<List<MemeTemplate>> fetchMemes();
}

/// Implementation
class RemoteDataSourceImpl implements RemoteDataSource {
  final Dio dio;

  RemoteDataSourceImpl(this.dio);

  @override
  Future<List<MemeTemplate>> fetchMemes() async {
    try {
      final response = await dio.get('https://api.imgflip.com/get_memes');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final memes = response.data['data']['memes'] as List;
        return memes.map((e) => MemeTemplate.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load meme templates');
      }
    } catch (e) {
      throw Exception('Dio error fetching memes: $e');
    }
  }
}

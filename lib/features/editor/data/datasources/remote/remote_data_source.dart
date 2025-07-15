import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meme_editor/features/editor/domain/entities/meme_template.dart';

/// Abstract interface
abstract class RemoteDataSource {
  Future<List<MemeTemplate>> fetchMemes();
}

/// Implementation
class RemoteDataSourceImpl implements RemoteDataSource {
  final http.Client client;

  RemoteDataSourceImpl(this.client);

  @override
  Future<List<MemeTemplate>> fetchMemes() async {
    final response = await client.get(
      Uri.parse('https://api.imgflip.com/get_memes'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final memes = data['data']['memes'] as List;
      return memes.map((e) => MemeTemplate.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load meme templates');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meme_editor/features/editor/domain/entities/meme_template.dart';
import '../../domain/entities/meme.dart';
import '../../domain/repositories/meme_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../datasources/remote/remote_data_source.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MemeRepositoryImpl implements MemeRepository {
  final RemoteDataSource remote;
  final LocalDataSource local;

  MemeRepositoryImpl({required this.remote, required this.local});

  // cache images by downloading images manually
  Future<Meme> _memeFromTemplate(
    MemeTemplate template,
    List<Meme> existingMemes,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${template.name.hashCode}.jpg';
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);

    if (!file.existsSync()) {
      try {
        final response = await Dio().get<List<int>>(
          template.url,
          options: Options(responseType: ResponseType.bytes),
        );
        await file.writeAsBytes(response.data!);
        debugPrint('[Image Download] Saved ${template.name} to $filePath');
      } catch (e) {
        debugPrint('[Image Download Error] $e');
        throw Exception('Failed to download meme image: $e');
      }
    } else {
      debugPrint('[Image Cache] Using existing file: $filePath');
    }

    final existing = existingMemes.firstWhere(
      (m) => m.id == template.name,
      orElse: () => Meme(id: template.name, imagePath: filePath, elements: []),
    );

    return Meme(
      id: template.name,
      imagePath: filePath,
      elements: existing.elements,
    );
  }

  // cache
  @override
  Future<List<Meme>> getAllMemes() async {
    return local.getCachedMemes();
  }

  // api
  @override
  Future<List<MemeTemplate>> getTemplates() async {
    try {
      final remoteTemplates = await remote.fetchMemes();
      debugPrint("Fetched ${remoteTemplates.length} templates.");

      //Load cached memes only once
      final existingCached = local.getCachedMemes();

      //Pass it into the loop
      final memesToCache = await Future.wait(
        remoteTemplates.map(
          (template) => _memeFromTemplate(template, existingCached),
        ),
      );

      await local.cacheMemes(memesToCache);

      return remoteTemplates;
    } catch (e) {
      debugPrint('Error fetching meme templates: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateMeme(Meme meme) async {
    await local.updateMeme(meme);
  }
}

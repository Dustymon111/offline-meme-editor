import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import '../../../domain/entities/meme.dart';

/// Interface
abstract class LocalDataSource {
  Future<void> cacheMemes(List<Meme> memes);
  List<Meme> getCachedMemes();
}

/// Implementation
class LocalDataSourceImpl implements LocalDataSource {
  final Box<Meme> memeBox;

  LocalDataSourceImpl(this.memeBox);

  @override
  Future<void> cacheMemes(List<Meme> memes) async {
    for (final meme in memes) {
      await memeBox.put(meme.id, meme);
      debugPrint('[Hive] Cached meme: ${meme.id}, path: ${meme.imagePath}');
    }
  }

  @override
  List<Meme> getCachedMemes() {
    final memes = memeBox.values.toList();
    for (final meme in memes) {
      debugPrint('[Hive] Loaded meme: ${meme.id}, path: ${meme.imagePath}');
      debugPrint('[File Check] Exists: ${File(meme.imagePath).existsSync()}');
    }
    return memes;
  }
}

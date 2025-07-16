import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import '../../../domain/entities/meme.dart';

/// Interface
abstract class LocalDataSource {
  Future<void> cacheMemes(List<Meme> memes);
  List<Meme> getCachedMemes();
  Future<void> updateMeme(Meme meme);
}

/// Implementation
class LocalDataSourceImpl implements LocalDataSource {
  final Box<Meme> memeBox;

  LocalDataSourceImpl(this.memeBox);

  @override
  Future<void> cacheMemes(List<Meme> memes) async {
    for (final meme in memes) {
      final existing = memeBox.get(meme.id);
      if (existing != null && existing.imagePath == meme.imagePath) {
        final preserved = meme.copyWith(elements: existing.elements);
        await memeBox.put(meme.id, preserved);
        debugPrint('[Hive] Updated meme with preserved elements: ${meme.id}');
      } else {
        await memeBox.put(meme.id, meme);
        debugPrint('[Hive] Cached new meme: ${meme.id}');
      }
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

  @override
  Future<void> updateMeme(Meme meme) async {
    await memeBox.put(meme.id, meme);
    debugPrint('[Hive] Updated meme: ${meme.id}');
    debugPrint(
      '[Hive] Meme Elements: ${meme.elements[meme.elements.length - 1].content.toString()}',
    );
    debugPrint(
      '[Hive] Meme Elements Count: ${meme.elements.length.toString()}',
    );
  }
}

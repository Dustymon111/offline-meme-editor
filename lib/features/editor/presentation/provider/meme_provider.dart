import 'package:flutter/material.dart';
import 'package:meme_editor/features/editor/domain/entities/meme.dart';
import 'package:meme_editor/features/editor/domain/repositories/meme_repository.dart';

class MemeProvider with ChangeNotifier {
  final MemeRepository repository;

  MemeProvider(this.repository);

  List<Meme> _memes = [];
  List<Meme> get memes => _memes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadMemes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _memes = await repository.getAllMemes();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}

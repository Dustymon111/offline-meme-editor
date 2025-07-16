import 'package:flutter/material.dart';
import 'package:meme_editor/features/editor/domain/entities/meme.dart';
import 'package:meme_editor/features/editor/domain/repositories/meme_repository.dart';
import '../../domain/entities/meme_element.dart';

class EditorProvider with ChangeNotifier {
  final MemeRepository repository;
  late Meme _currentMeme;

  EditorProvider({required this.repository});

  final List<MemeElement> _elements = [];
  final List<List<MemeElement>> _history = [];
  int _historyIndex = -1;

  List<MemeElement> get elements => List.unmodifiable(_elements);

  void saveToHistory() {
    final snapshot = _elements.map((e) => e.copyWith()).toList();

    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    _history.add(snapshot);
    _historyIndex++;
  }

  Future<void> loadMemeById(String id) async {
    final all = await repository.getAllMemes();
    _currentMeme = all.firstWhere((m) => m.id == id);
    _elements
      ..clear()
      ..addAll(_currentMeme.elements.map((e) => e.copyWith()));
    _history.clear();
    _historyIndex = -1;
    saveToHistory();
    notifyListeners();
  }

  void addElement(MemeElement element) {
    _elements.add(element);
    saveToHistory();
    notifyListeners();
  }

  void updateElement(String id, MemeElement updated) {
    final index = _elements.indexWhere((e) => e.id == id);
    if (index != -1) {
      _elements[index] = updated;
      notifyListeners();
    }
    saveMeme();
  }

  // void removeElement(String id) {
  //   _elements.removeWhere((e) => e.id == id);
  //   saveToHistory();
  //   notifyListeners();
  //   saveMeme();
  // }

  void undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      _restoreFromHistory();
      notifyListeners();
    }
  }

  void redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      _restoreFromHistory();
      notifyListeners();
    }
  }

  void _restoreFromHistory() {
    _elements
      ..clear()
      ..addAll(_history[_historyIndex].map((e) => e.copyWith()));
  }

  void clear() {
    _elements.clear();
    _history.clear();
    _historyIndex = -1;
    notifyListeners();
  }

  Future<void> saveMeme() async {
    final updated = _currentMeme.copyWith(elements: [..._elements]);
    await repository.updateMeme(updated);
  }
}

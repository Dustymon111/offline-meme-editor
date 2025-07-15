import 'package:flutter/material.dart';
import '../../domain/entities/meme_element.dart';

class EditorProvider with ChangeNotifier {
  final List<MemeElement> _elements = [];
  final List<List<MemeElement>> _history = [];
  int _historyIndex = -1;

  List<MemeElement> get elements => List.unmodifiable(_elements);

  EditorProvider() {
    saveToHistory();
  }

  void saveToHistory() {
    final snapshot = _elements.map((e) => e.copyWith()).toList();

    // Trim future history if undo was used before this
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    _history.add(snapshot);
    _historyIndex++;
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
      notifyListeners(); // Don't save yet — wait for onPanEnd etc.
    }
  }

  void removeElement(String id) {
    _elements.removeWhere((e) => e.id == id);
    saveToHistory();
    notifyListeners();
  }

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
}

import 'package:flutter/material.dart';
import '../../domain/entities/meme_template.dart';
import '../../domain/entities/meme.dart';
import '../../domain/repositories/meme_repository.dart';

class HomeProvider with ChangeNotifier {
  final MemeRepository repository;

  HomeProvider(this.repository);

  List<MemeTemplate> _fetchedTemplates = [];
  List<Meme> _cachedMemes = [];
  List<MemeTemplate> get filteredTemplates => _filteredTemplates;
  List<Meme> get filteredCachedMemes => _filteredMemes;

  bool _isLoading = false;
  bool _isOnline = true;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String get searchQuery => _searchQuery;

  Future<void> init() async {
    await loadCachedMemes();
    if (_isOnline) {
      await fetchTemplates();
    }
  }

  Future<void> loadCachedMemes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cachedMemes = await repository.getAllMemes();
      debugPrint('[Init] Loaded ${_cachedMemes.length} memes from cache.');
    } catch (e) {
      debugPrint('[Init] Failed to load cached memes: $e');
      _cachedMemes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  List<String> get currentImageUrls {
    if (_isOnline) {
      return _filteredTemplates.map((e) => e.url).toList();
    } else {
      return _filteredMemes.map((e) => e.imagePath).toList();
    }
  }

  // Filtered templates
  List<MemeTemplate> get _filteredTemplates {
    if (_searchQuery.isEmpty) return _fetchedTemplates;
    return _fetchedTemplates
        .where((m) => m.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Filtered offline memes
  List<Meme> get _filteredMemes {
    if (_searchQuery.isEmpty) return _cachedMemes;
    return _cachedMemes
        .where((m) => m.id.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> fetchTemplates() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isOnline) {
        _fetchedTemplates = await repository.getTemplates();
      } else {
        _cachedMemes = await repository.getAllMemes();
      }
    } catch (e) {
      debugPrint('Failed to fetch memes: $e');
      _fetchedTemplates = [];
      _cachedMemes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleOnlineMode() {
    _isOnline = !_isOnline;
    notifyListeners();

    if (_isOnline) {
      fetchTemplates(); // refetch from API
    } else {
      loadCachedMemes(); // load local cache
    }
  }
}

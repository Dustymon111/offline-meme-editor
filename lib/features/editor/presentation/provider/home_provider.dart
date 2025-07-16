import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:meme_editor/features/editor/domain/entities/meme_template.dart';
import '../../domain/entities/meme.dart';
import '../../domain/repositories/meme_repository.dart';

class HomeProvider with ChangeNotifier {
  final MemeRepository repository;

  HomeProvider(this.repository);

  List<Meme> _cachedMemes = [];
  List<MemeTemplate> _templates = [];
  List<Meme> get filteredCachedMemes => _filteredMemes;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  bool _isLoading = false;
  bool _isOnline = true;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String get searchQuery => _searchQuery;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check initial connectivity state
      await _checkInitialConnectivity();

      // Start listening for connectivity changes
      _startConnectivityListener();

      // Load cached memes first
      await _loadCachedMemes();

      // If online, fetch fresh templates
      if (_isOnline) {
        await fetchTemplates();
      }
    } catch (e) {
      debugPrint('Error during initialization: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      if (connectivityResults.isNotEmpty) {
        await _updateConnectivityStatus(connectivityResults.first);
      } else {
        await _updateConnectivityStatus(ConnectivityResult.none);
      }
    } catch (e) {
      debugPrint('Error checking initial connectivity: $e');
      _isOnline = false;
    }
  }

  void _startConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) async {
        if (results.isNotEmpty) {
          await _updateConnectivityStatus(results.first);
        } else {
          await _updateConnectivityStatus(ConnectivityResult.none);
        }
      },
      onError: (error) {
        debugPrint('Connectivity listener error: $error');
      },
    );
  }

  // Update connectivity status based on connectivity result
  Future<void> _updateConnectivityStatus(ConnectivityResult result) async {
    bool wasOnline = _isOnline;

    if (result == ConnectivityResult.none) {
      _isOnline = false;
    } else {
      _isOnline = await _hasInternetConnection();
    }

    // If connectivity changed, notify listeners and update data
    if (wasOnline != _isOnline) {
      notifyListeners();

      if (_isOnline) {
        await fetchTemplates();
      } else {
        await _loadCachedMemes();
      }
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadCachedMemes() async {
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

  // Filtered memes (from cache)
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
        _templates = await repository.getTemplates();
      } else {
        _cachedMemes = await repository.getAllMemes();
      }
    } catch (e) {
      debugPrint('Failed to fetch memes: $e');
      _cachedMemes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleOnlineMode(BuildContext context) {
    _isOnline = !_isOnline;
    notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isOnline ? 'Switched to Online Mode' : 'Switched to Offline Mode',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    try {
      fetchTemplates();
    } catch (e) {
      _isOnline = false;
      _loadCachedMemes();
    }
  }
}

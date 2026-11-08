import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/sample_data.dart';
import '../models/book_model.dart';
import '../models/city_model.dart';
import '../models/hobby_model.dart';

/// Shared state with separate category IDs and isolated copies of sample data.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._prefs) {
    loadFavorites();
  }
  final SharedPreferences _prefs;
  static const storageKey = 'favorites.preferences.v1';
  final cities = sampleCities
      .map(
        (c) => CityModel(
          id: c.id,
          cityName: c.cityName,
          cityImage: c.cityImage,
          isFavorite: false,
        ),
      )
      .toList();
  final hobbies = sampleHobbies
      .map(
        (h) => HobbyModel(
          id: h.id,
          hobbyName: h.hobbyName,
          hobbyIcon: h.hobbyIcon,
          isFavorite: false,
        ),
      )
      .toList();
  final books = sampleBooks
      .map(
        (b) => BookModel(
          id: b.id,
          bookTitle: b.bookTitle,
          bookAuthor: b.bookAuthor,
          isFavorite: false,
        ),
      )
      .toList();
  ThemeMode themeMode = ThemeMode.system;
  String? storageError;
  Future<void> _pending = Future.value();
  bool _disposed = false;
  int get favoriteCount =>
      cities.where((c) => c.isFavorite).length +
      hobbies.where((h) => h.isFavorite).length +
      books.where((b) => b.isFavorite).length;

  void loadFavorites() {
    try {
      final raw = _prefs.getString(storageKey);
      final data = raw == null
          ? <String, dynamic>{}
          : jsonDecode(raw) as Map<String, dynamic>;
      final cityIds =
          data['cities'] as List? ??
          _prefs.getStringList('favoriteCities') ??
          [];
      final hobbyIds = data['hobbies'] as List? ?? [];
      final bookIds = data['books'] as List? ?? [];
      for (final c in cities) {
        c.isFavorite = cityIds.contains(c.id.toString());
      }
      for (final h in hobbies) {
        h.isFavorite = hobbyIds.contains(h.id.toString());
      }
      for (final b in books) {
        b.isFavorite = bookIds.contains(b.id.toString());
      }
      themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == data['theme'],
        orElse: () => ThemeMode.system,
      );
    } catch (_) {
      storageError =
          'Saved preferences could not be read. Your changes will replace them.';
    }
  }

  Future<void> toggleCityFavorite(int id) {
    final item = cities.firstWhere((c) => c.id == id);
    item.isFavorite = !item.isFavorite;
    return _changed();
  }

  Future<void> toggleHobbyFavorite(int id) {
    final item = hobbies.firstWhere((h) => h.id == id);
    item.isFavorite = !item.isFavorite;
    return _changed();
  }

  Future<void> toggleBookFavorite(int id) {
    final item = books.firstWhere((b) => b.id == id);
    item.isFavorite = !item.isFavorite;
    return _changed();
  }

  Future<void> setThemeMode(ThemeMode mode) {
    themeMode = mode;
    return _changed();
  }

  Future<void> clearFavorites() {
    for (final c in cities) {
      c.isFavorite = false;
    }
    for (final h in hobbies) {
      h.isFavorite = false;
    }
    for (final b in books) {
      b.isFavorite = false;
    }
    return _changed();
  }

  Future<void> _changed() {
    notifyListeners();
    return saveFavorites();
  }

  /// Capture snapshots and serialize writes so rapid taps cannot save stale state.
  Future<void> saveFavorites() {
    final snapshot = jsonEncode({
      'cities': cities
          .where((c) => c.isFavorite)
          .map((c) => c.id.toString())
          .toList(),
      'hobbies': hobbies
          .where((h) => h.isFavorite)
          .map((h) => h.id.toString())
          .toList(),
      'books': books
          .where((b) => b.isFavorite)
          .map((b) => b.id.toString())
          .toList(),
      'theme': themeMode.name,
    });
    _pending = _pending.then((_) async {
      try {
        if (!await _prefs.setString(storageKey, snapshot)) {
          throw StateError('Preferences write failed');
        }
        storageError = null;
      } catch (_) {
        storageError =
            'Changes could not be saved to this device. Please retry.';
      }
      if (!_disposed) notifyListeners();
    });
    return _pending;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

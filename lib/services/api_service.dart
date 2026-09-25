import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/movie.dart';

const _key = '353460b';
const _base = 'http://www.omdbapi.com/?apikey=$_key';

class ApiService {
  static Future<List<Movie>> search(String query, {String type = '', String year = ''}) async {
    var url = '$_base&s=${Uri.encodeComponent(query)}';
    if (type.isNotEmpty) url += '&type=$type';
    if (year.isNotEmpty) url += '&y=$year';
    try {
      final r = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      final j = jsonDecode(r.body);
      if (j['Response'] == 'True') {
        return (j['Search'] as List).map((e) => Movie.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<Movie?> detail(String imdbId) async {
    try {
      final r = await http.get(Uri.parse('$_base&i=$imdbId&plot=full')).timeout(const Duration(seconds: 15));
      final j = jsonDecode(r.body);
      if (j['Response'] == 'True') return Movie.fromJson(j);
    } catch (_) {}
    return null;
  }

  static Future<String> translate(String text) async {
    try {
      final url = 'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=en|ar';
      final r = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      final j = jsonDecode(r.body);
      return j['responseData']['translatedText'] ?? text;
    } catch (_) {}
    return text;
  }
}

class FavoritesProvider extends ChangeNotifier {
  List<Movie> _favs = [];
  List<Movie> get favs => _favs;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorites') ?? [];
    _favs = list.map(Movie.fromStorageString).toList();
    notifyListeners();
  }

  Future<void> add(Movie m) async {
    if (_favs.any((f) => f.imdbId == m.imdbId)) return;
    _favs.add(m);
    await _save();
    notifyListeners();
  }

  Future<void> remove(String imdbId) async {
    _favs.removeWhere((f) => f.imdbId == imdbId);
    await _save();
    notifyListeners();
  }

  bool isFav(String imdbId) => _favs.any((f) => f.imdbId == imdbId);

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favs.map((m) => m.toStorageString()).toList());
  }
}

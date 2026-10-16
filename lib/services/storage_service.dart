import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage and preferences
class StorageService {
  static const String _baseUrlKey = 'base_url';
  static const String _defaultBaseUrl = 'http://10.63.232.158:8080';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Migration: fix any stored URL that contains path segments like /api/live-url
    final stored = _prefs?.getString(_baseUrlKey);
    if (stored != null && stored.contains('/api/')) {
      final uri = Uri.parse(stored);
      final cleanUrl = '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
      await _prefs?.setString(_baseUrlKey, cleanUrl);
    }
  }

  String getBaseUrl() {
    return _prefs?.getString(_baseUrlKey) ?? _defaultBaseUrl;
  }

  Future<void> setBaseUrl(String url) async {
    await _prefs?.setString(_baseUrlKey, url);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }
}


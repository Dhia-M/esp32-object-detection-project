import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Provider for app-wide state (settings, base URL, etc.)
class AppStateProvider extends ChangeNotifier {
  final StorageService _storageService;
  String _baseUrl;

  AppStateProvider(this._storageService) : _baseUrl = _storageService.getBaseUrl();

  String get baseUrl => _baseUrl;

  Future<void> updateBaseUrl(String newUrl) async {
    if (_baseUrl != newUrl) {
      _baseUrl = newUrl;
      await _storageService.setBaseUrl(newUrl);
      notifyListeners();
    }
  }
}


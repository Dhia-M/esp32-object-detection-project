import 'package:flutter/material.dart';
import '../models/clip.dart';
import '../services/api_service.dart';

/// Provider for managing recorded clips
class ClipsProvider extends ChangeNotifier {
  final ApiService apiService;
  
  List<Clip> _clips = [];
  bool _isLoading = false;
  String? _error;

  ClipsProvider({required this.apiService});

  List<Clip> get clips => _clips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all clips from server
  Future<void> loadClips() async {
    _setLoading(true);
    _setError(null);

    try {
      _clips = await apiService.getClips();
      // Sort by timestamp (newest first)
      _clips.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    } catch (e) {
      _setError('Failed to load clips: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh clips list
  Future<void> refreshClips() async {
    await loadClips();
  }

  /// Get a specific clip by ID
  Future<Clip?> getClip(String id) async {
    try {
      return await apiService.getClip(id);
    } catch (e) {
      _setError('Failed to load clip: $e');
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}


import 'dart:async';
import 'package:flutter/material.dart';
import '../models/detection.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/mjpeg_player_service.dart';

/// Provider for live video streaming and recording
class VideoProvider extends ChangeNotifier {
  final ApiService apiService;
  final StorageService storageService;
  
  MjpegPlayerService? _mjpegPlayer;
  List<Detection> _detections = [];
  bool _isRecording = false;
  String? _currentClipId;
  bool _isLoading = false;
  String? _error;
  Timer? _detectionTimer;

  VideoProvider({required this.apiService, required this.storageService});

  MjpegPlayerService? get mjpegPlayer => _mjpegPlayer;
  List<Detection> get detections => _detections;
  bool get isRecording => _isRecording;
  String? get currentClipId => _currentClipId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isStreamReady => _mjpegPlayer?.isInitialized ?? false;

  /// Initialize video stream
  Future<void> initializeStream() async {
    _setLoading(true);
    _setError(null);

    try {
      // Dispose previous player if any
      _mjpegPlayer?.dispose();
      _mjpegPlayer = null;

      // Build MJPEG stream URL directly from the current base URL
      final baseUrl = storageService.getBaseUrl();
      final streamUrl = '$baseUrl/api/stream';

      _mjpegPlayer = MjpegPlayerService();
      await _mjpegPlayer!.initialize(streamUrl);

      // Start polling for detections
      _startDetectionPolling();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize stream: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Build the stream view widget
  Widget buildStreamView() {
    if (_mjpegPlayer == null) {
      return const Center(child: Text('Stream not initialized', style: TextStyle(color: Colors.white70)));
    }
    return _mjpegPlayer!.buildView();
  }

  /// Start polling for detection updates
  void _startDetectionPolling() {
    _detectionTimer?.cancel();
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      try {
        final newDetections = await apiService.getDetections();
        if (newDetections != _detections) {
          _detections = newDetections;
          notifyListeners();
        }
      } catch (e) {
        // Silently fail - don't spam errors for detection polling
      }
    });
  }

  /// Stop detection polling
  void _stopDetectionPolling() {
    _detectionTimer?.cancel();
    _detectionTimer = null;
  }

  /// Start recording
  Future<void> startRecording({int? duration}) async {
    if (_isRecording) return;

    _setLoading(true);
    _setError(null);

    try {
      final response = await apiService.startRecording(duration: duration);
      if (response.success) {
        _isRecording = true;
        _currentClipId = response.clipId;
        notifyListeners();
      } else {
        throw Exception(response.message ?? 'Failed to start recording');
      }
    } catch (e) {
      _setError('Failed to start recording: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Stop recording
  Future<void> stopRecording() async {
    if (!_isRecording) return;

    _setLoading(true);
    _setError(null);

    try {
      final response = await apiService.stopRecording();
      if (response.success) {
        _isRecording = false;
        _currentClipId = null;
        notifyListeners();
      } else {
        throw Exception(response.message ?? 'Failed to stop recording');
      }
    } catch (e) {
      _setError('Failed to stop recording: $e');
    } finally {
      _setLoading(false);
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

  @override
  void dispose() {
    _stopDetectionPolling();
    _mjpegPlayer?.dispose();
    super.dispose();
  }
}


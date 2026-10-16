import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clip.dart';
import '../models/detection.dart';
import '../models/api_response.dart';
import 'storage_service.dart';

/// Service for communicating with the backend API
class ApiService {
  final StorageService _storageService;

  ApiService(this._storageService);

  String get _baseUrl => _storageService.getBaseUrl();

  Future<T> _get<T>(String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return fromJson(jsonData);
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<T> _post<T>(
    String endpoint,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body != null ? json.encode(body) : null,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return fromJson(jsonData);
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// GET /api/status
  Future<StatusResponse> getStatus() async {
    return _get('/api/status', (json) => StatusResponse.fromJson(json));
  }

  /// POST /api/record
  /// body: { "duration": 30 } (optional, in seconds)
  Future<RecordResponse> startRecording({int? duration}) async {
    return _post(
      '/api/record',
      duration != null ? {'duration': duration} : null,
      (json) => RecordResponse.fromJson(json),
    );
  }

  /// POST /api/record/stop
  /// Stops the current recording
  Future<RecordResponse> stopRecording() async {
    return _post(
      '/api/record/stop',
      null,
      (json) => RecordResponse.fromJson(json),
    );
  }

  /// GET /api/clips
  Future<List<Clip>> getClips() async {
    try {
      final url = Uri.parse('$_baseUrl/api/clips');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          return jsonData
              .map((item) => Clip.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (jsonData is Map && jsonData.containsKey('clips')) {
          final clipsList = jsonData['clips'] as List;
          return clipsList
              .map((item) => Clip.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// GET /api/clips/{id}
  Future<Clip> getClip(String id) async {
    return _get('/api/clips/$id', (json) => Clip.fromJson(json));
  }

  /// WebSocket or polling endpoint for real-time detections
  /// This would typically be a WebSocket, but for simplicity we'll use polling
  /// GET /api/detections
  Future<List<Detection>> getDetections() async {
    try {
      final url = Uri.parse('$_baseUrl/api/detections');
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          return jsonData
              .map((item) => Detection.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (jsonData is Map && jsonData.containsKey('detections')) {
          final detectionsList = jsonData['detections'] as List;
          return detectionsList
              .map((item) => Detection.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}


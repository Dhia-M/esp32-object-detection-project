import 'package:intl/intl.dart';

/// Represents a recorded video clip
class Clip {
  final String id;
  final DateTime timestamp;
  final int duration; // in seconds
  final String thumbnailUrl;
  final String videoUrl;
  final String objectType;

  Clip({
    required this.id,
    required this.timestamp,
    required this.duration,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.objectType,
  });

  factory Clip.fromJson(Map<String, dynamic> json) {
    return Clip(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      duration: json['duration'] as int,
      thumbnailUrl: json['thumbnailUrl'] as String,
      videoUrl: json['videoUrl'] as String,
      objectType: json['objectType'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'objectType': objectType,
    };
  }

  String get formattedTimestamp {
    return DateFormat('MMM dd, yyyy • HH:mm').format(timestamp);
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}


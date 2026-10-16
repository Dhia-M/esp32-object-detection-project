/// API response models
class StatusResponse {
  final bool isOnline;
  final String model;
  final String resolution;
  final String? timestamp;

  StatusResponse({
    required this.isOnline,
    required this.model,
    required this.resolution,
    this.timestamp,
  });

  factory StatusResponse.fromJson(Map<String, dynamic> json) {
    return StatusResponse(
      isOnline: json['esp32_connected'] as bool? ?? json['isOnline'] as bool? ?? false,
      model: json['model'] as String? ?? 'unknown',
      resolution: json['resolution'] as String? ?? 'N/A',
      timestamp: json['timestamp'] as String?,
    );
  }
}


class LiveUrlResponse {
  final String rtspUrl;
  final String? mjpegUrl;
  final String? hlsUrl;
  final String streamType; // 'rtsp', 'mjpeg', or 'hls'

  LiveUrlResponse({
    required this.rtspUrl,
    this.mjpegUrl,
    this.hlsUrl,
    required this.streamType,
  });

  factory LiveUrlResponse.fromJson(Map<String, dynamic> json) {
    return LiveUrlResponse(
      rtspUrl: json['rtspUrl'] as String? ?? '',
      mjpegUrl: json['mjpegUrl'] as String?,
      hlsUrl: json['hlsUrl'] as String?,
      streamType: json['streamType'] as String? ?? 'rtsp',
    );
  }
}

class RecordResponse {
  final String clipId;
  final bool success;
  final String? message;

  RecordResponse({
    required this.clipId,
    required this.success,
    this.message,
  });

  factory RecordResponse.fromJson(Map<String, dynamic> json) {
    return RecordResponse(
      clipId: json['clipId'] as String,
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
    );
  }
}


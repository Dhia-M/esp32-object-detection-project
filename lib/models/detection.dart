/// Represents a detected object with bounding box information
class Detection {
  final String label;
  final double confidence;
  final double x; // normalized (0-1)
  final double y; // normalized (0-1)
  final double width; // normalized (0-1)
  final double height; // normalized (0-1)

  Detection({
    required this.label,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }
}


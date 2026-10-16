import 'package:flutter/material.dart';
import '../models/detection.dart';

/// Custom painter for drawing detection bounding boxes on video
class DetectionOverlayPainter extends CustomPainter {
  final List<Detection> detections;
  final Size videoSize;

  DetectionOverlayPainter({
    required this.detections,
    required this.videoSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) return;

    // Calculate scale factors
    final scaleX = size.width / videoSize.width;
    final scaleY = size.height / videoSize.height;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          offset: const Offset(1, 1),
          blurRadius: 2,
          color: Colors.black.withOpacity(0.8),
        ),
      ],
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    for (final detection in detections) {
      // Convert normalized coordinates to pixel coordinates
      final x = detection.x * size.width;
      final y = detection.y * size.height;
      final width = detection.width * size.width;
      final height = detection.height * size.height;

      // Draw bounding box
      final paint = Paint()
        ..color = _getColorForLabel(detection.label)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final rect = Rect.fromLTWH(x, y, width, height);
      canvas.drawRect(rect, paint);

      // Draw label and confidence
      final label = '${detection.label} ${(detection.confidence * 100).toStringAsFixed(0)}%';
      textPainter.text = TextSpan(text: label, style: textStyle);
      textPainter.layout();

      // Draw background for text
      final textBackgroundRect = Rect.fromLTWH(
        x,
        y - textPainter.height - 4,
        textPainter.width + 8,
        textPainter.height + 4,
      );
      final backgroundPaint = Paint()
        ..color = _getColorForLabel(detection.label).withOpacity(0.7);
      canvas.drawRect(textBackgroundRect, backgroundPaint);

      // Draw text
      textPainter.paint(canvas, Offset(x + 4, y - textPainter.height));
    }
  }

  Color _getColorForLabel(String label) {
    // Assign colors based on object type
    switch (label.toLowerCase()) {
      case 'person':
        return Colors.red;
      case 'car':
        return Colors.blue;
      case 'bicycle':
        return Colors.green;
      case 'dog':
      case 'cat':
        return Colors.orange;
      default:
        return Colors.yellow;
    }
  }

  @override
  bool shouldRepaint(DetectionOverlayPainter oldDelegate) {
    return detections != oldDelegate.detections ||
        videoSize != oldDelegate.videoSize;
  }
}

/// Widget that overlays detection bounding boxes on video
class DetectionOverlay extends StatelessWidget {
  final List<Detection> detections;
  final Size videoSize;
  final Widget child;

  const DetectionOverlay({
    super.key,
    required this.detections,
    required this.videoSize,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (detections.isNotEmpty)
          CustomPaint(
            painter: DetectionOverlayPainter(
              detections: detections,
              videoSize: videoSize,
            ),
            size: Size.infinite,
          ),
      ],
    );
  }
}


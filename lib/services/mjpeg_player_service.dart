import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Custom MJPEG stream player that reads multipart/x-mixed-replace responses
/// and renders each JPEG frame as an Image widget.
class MjpegPlayerService {
  String? _url;
  bool _isInitialized = false;
  bool _isRunning = false;
  http.Client? _client;

  final StreamController<Uint8List> _frameController =
      StreamController<Uint8List>.broadcast();

  Stream<Uint8List> get frameStream => _frameController.stream;
  bool get isInitialized => _isInitialized;

  Future<void> initialize(String url) async {
    _url = url;
    _isRunning = true;
    _isInitialized = true;
    _startStreaming();
  }

  void _startStreaming() async {
    _client = http.Client();

    while (_isRunning) {
      try {
        final request = http.Request('GET', Uri.parse(_url!));
        final response = await _client!.send(request);

        if (response.statusCode != 200) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        // Read the MJPEG multipart stream
        final List<int> buffer = [];
        bool foundStart = false;

        await for (final chunk in response.stream) {
          if (!_isRunning) break;

          for (int i = 0; i < chunk.length; i++) {
            // Look for JPEG start marker (0xFF 0xD8)
            if (i < chunk.length - 1 &&
                chunk[i] == 0xFF &&
                chunk[i + 1] == 0xD8) {
              buffer.clear();
              foundStart = true;
            }

            if (foundStart) {
              buffer.add(chunk[i]);
            }

            // Look for JPEG end marker (0xFF 0xD9)
            if (foundStart &&
                buffer.length >= 2 &&
                chunk[i] == 0xD9 &&
                (buffer.length >= 2 && buffer[buffer.length - 2] == 0xFF)) {
              // Complete JPEG frame
              if (!_frameController.isClosed) {
                _frameController.add(Uint8List.fromList(buffer));
              }
              buffer.clear();
              foundStart = false;
            }
          }
        }
      } catch (e) {
        if (_isRunning) {
          // Retry after a short delay on error
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
  }

  Widget buildView() {
    return StreamBuilder<Uint8List>(
      stream: frameStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            gaplessPlayback: true, // Prevents flickering between frames
            fit: BoxFit.contain,
          );
        }
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Connecting to stream...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        );
      },
    );
  }

  void dispose() {
    _isRunning = false;
    _client?.close();
    _client = null;
    _frameController.close();
    _isInitialized = false;
  }
}

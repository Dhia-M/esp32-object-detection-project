import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../widgets/detection_overlay.dart';
import '../models/detection.dart';

/// Screen for displaying live video stream with detection overlay
class LiveViewScreen extends StatefulWidget {
  const LiveViewScreen({super.key});

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  Timer? _initTimer;

  @override
  void initState() {
    super.initState();
    // Initialize stream when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoProvider>().initializeStream();
    });
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live View'),
        actions: [
          Consumer<VideoProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<VideoProvider>(
        builder: (context, provider, _) {
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.initializeStream();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!provider.isStreamReady) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Initializing stream...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Video player with detection overlay
              Center(
                child: DetectionOverlay(
                  detections: provider.detections,
                  videoSize: const Size(1920, 1080), // Default video size, adjust if needed
                  child: provider.buildStreamView(),
                ),
              ),
              // Recording indicator
              if (provider.isRecording)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'REC',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Detection count badge
              if (provider.detections.isNotEmpty)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${provider.detections.length} detection${provider.detections.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<VideoProvider>(
        builder: (context, provider, _) {
          return FloatingActionButton.extended(
            onPressed: provider.isLoading
                ? null
                : () {
                    if (provider.isRecording) {
                      provider.stopRecording();
                    } else {
                      provider.startRecording();
                    }
                  },
            backgroundColor: provider.isRecording ? Colors.red : Colors.blue,
            icon: Icon(provider.isRecording ? Icons.stop : Icons.fiber_manual_record),
            label: Text(provider.isRecording ? 'Stop Recording' : 'Record'),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}


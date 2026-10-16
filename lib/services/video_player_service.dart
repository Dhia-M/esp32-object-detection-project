import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

/// Abstract video player service supporting RTSP, MJPEG, and HLS
enum StreamType { rtsp, mjpeg, hls }

abstract class VideoPlayerService {
  Future<void> initialize(String url);
  Widget buildView();
  void dispose();
  bool get isInitialized;
}

/// RTSP player using flutter_vlc_player
class RTSPPlayerService extends VideoPlayerService {
  VlcPlayerController? _controller;
  String? _url;

  @override
  Future<void> initialize(String url) async {
    _url = url;
    _controller = VlcPlayerController.network(
      url,
      hwAcc: HwAcc.full,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(300),
        ]),
        subtitle: VlcSubtitleOptions([
          VlcSubtitleOptions.boldStyle(true),
          VlcSubtitleOptions.fontSize(30),
        ]),
        http: VlcHttpOptions([
          VlcHttpOptions.httpReconnect(true),
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
      ),
    );
    await _controller?.initialize();
  }

  @override
  Widget buildView() {
    if (_controller == null || !isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return VlcPlayer(
      controller: _controller!,
      aspectRatio: 16 / 9,
      placeholder: const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  bool get isInitialized => _controller?.value.isInitialized ?? false;
}

/// HLS/MJPEG player using video_player
class HLSPlayerService extends VideoPlayerService {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;

  @override
  Future<void> initialize(String url) async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await _controller!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller!,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      showControls: false,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            'Error: $errorMessage',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget buildView() {
    if (_chewieController == null || !isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Chewie(controller: _chewieController!);
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller?.dispose();
    _controller = null;
    _chewieController = null;
  }

  @override
  bool get isInitialized => _controller?.value.isInitialized ?? false;
}

/// Factory for creating appropriate video player service
class VideoPlayerServiceFactory {
  static VideoPlayerService create(StreamType type) {
    switch (type) {
      case StreamType.rtsp:
        return RTSPPlayerService();
      case StreamType.hls:
      case StreamType.mjpeg:
        return HLSPlayerService();
    }
  }
}


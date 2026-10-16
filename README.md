# AI Camera Client

A production-ready Flutter mobile application for connecting to a private AI video server with real-time object detection.

## Features

- **Live Video Streaming**: RTSP, HLS, and MJPEG support with low latency
- **AI Object Detection**: Real-time bounding boxes with labels and confidence scores
- **Manual Recording**: Start/stop recording with visual indicators
- **Clip Management**: View, play, and download recorded video clips
- **Dark Theme**: Material 3 design optimized for camera monitoring
- **Offline Support**: Configurable base URL with persistent storage

## Architecture

- **State Management**: Provider pattern for clean separation of concerns
- **Video Playback**: Abstracted video player service supporting multiple stream types
- **API Integration**: RESTful API client with proper error handling
- **Modular Design**: Organized folder structure with reusable components

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── detection.dart
│   ├── clip.dart
│   └── api_response.dart
├── services/                 # Business logic
│   ├── api_service.dart
│   ├── video_player_service.dart
│   └── storage_service.dart
├── providers/                # State management
│   ├── app_state_provider.dart
│   ├── video_provider.dart
│   └── clips_provider.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── live_view_screen.dart
│   ├── clips_screen.dart
│   ├── clip_player_screen.dart
│   └── settings_screen.dart
└── widgets/                  # Reusable widgets
    └── detection_overlay.dart
```

## Setup

1. **Install Flutter**: Ensure you have Flutter stable installed
   ```bash
   flutter --version
   ```

2. **Get Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Base URL**: 
   - Open the app and navigate to Settings
   - Enter your Tailscale IP (e.g., `http://100.64.0.1`)
   - The URL is persisted automatically

4. **Run the App**:
   ```bash
   flutter run
   ```

## API Endpoints

The app expects the following backend endpoints:

- `GET /api/status` - Server status
- `GET /api/live-url` - Get streaming URLs
- `POST /api/record` - Start recording
- `POST /api/record/stop` - Stop recording
- `GET /api/clips` - List all clips
- `GET /api/clips/{id}` - Get specific clip
- `GET /api/detections` - Get current detections (polling)

## Dependencies

- `provider` - State management
- `flutter_vlc_player` - RTSP streaming
- `video_player` & `chewie` - HLS/MJPEG playback
- `http` - API communication
- `shared_preferences` - Local storage
- `cached_network_image` - Image caching

## Platform Support

- ✅ Android (Primary)
- ⚠️ iOS (Optional - may require additional configuration)

## Notes

- The app assumes the backend is accessible via Tailscale VPN
- No authentication is required (VPN handles security)
- Detection polling runs at 500ms intervals for real-time updates
- Video player automatically selects the best available stream type

## License

This project is provided as-is for production use.


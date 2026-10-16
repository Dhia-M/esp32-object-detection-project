# Quick Start Guide

## Prerequisites

1. **Flutter SDK**: Install Flutter stable (3.0+)
   ```bash
   flutter doctor
   ```

2. **Android Studio / VS Code**: For development and debugging

3. **Tailscale VPN**: Ensure your device is connected to the same Tailscale network as the server

## Setup Steps

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Backend URL

The app defaults to `http://100.64.0.1`. To change it:

- Run the app
- Navigate to **Settings** tab
- Edit the **Base URL** field
- Enter your Tailscale IP (e.g., `http://100.123.45.67`)
- Tap the checkmark to save

### 3. Run on Android

```bash
flutter run
```

Or use Android Studio/VS Code to run and debug.

## Backend API Requirements

Your backend server should implement these endpoints:

### Status Check
```
GET /api/status
Response: { "isOnline": true, "version": "1.0" }
```

### Live Stream URL
```
GET /api/live-url
Response: {
  "rtspUrl": "rtsp://...",
  "hlsUrl": "http://.../stream.m3u8",  // optional
  "mjpegUrl": "http://.../stream.mjpeg",  // optional
  "streamType": "rtsp"
}
```

### Start Recording
```
POST /api/record
Body: { "duration": 30 }  // optional, in seconds
Response: { "clipId": "abc123", "success": true }
```

### Stop Recording
```
POST /api/record/stop
Response: { "clipId": "abc123", "success": true }
```

### List Clips
```
GET /api/clips
Response: [
  {
    "id": "abc123",
    "timestamp": "2024-01-01T12:00:00Z",
    "duration": 30,
    "thumbnailUrl": "http://.../thumb.jpg",
    "videoUrl": "http://.../video.mp4",
    "objectType": "person"
  }
]
```

### Get Clip Details
```
GET /api/clips/{id}
Response: { ... same as clip object above ... }
```

### Get Detections (Polling)
```
GET /api/detections
Response: [
  {
    "label": "person",
    "confidence": 0.95,
    "x": 0.1,
    "y": 0.2,
    "width": 0.3,
    "height": 0.4
  }
]
```

**Note**: Coordinates are normalized (0-1) relative to video dimensions.

## Troubleshooting

### Stream Not Loading
- Check Tailscale connection
- Verify base URL in Settings
- Check server logs for connection attempts
- Try different stream types (RTSP → HLS → MJPEG)

### Detections Not Showing
- Ensure `/api/detections` endpoint returns valid JSON
- Check that coordinates are normalized (0-1)
- Verify polling is working (check network tab)

### Recording Fails
- Check server has write permissions
- Verify `/api/record` endpoint is accessible
- Check server logs for errors

### Clips Not Loading
- Verify `/api/clips` returns array of clip objects
- Check thumbnail URLs are accessible
- Ensure video URLs are valid

## Testing Without Backend

You can test the UI by mocking the API responses. Modify `api_service.dart` temporarily to return mock data.

## Next Steps

- Implement download functionality (currently placeholder)
- Add offline clip caching
- Add push notifications for detections
- Implement picture-in-picture mode


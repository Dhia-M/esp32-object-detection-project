#!/usr/bin/env python3
"""
ESP32-CAM AI Object Detection Server
- Receives MJPEG stream from ESP32-CAM
- Performs real-time object detection using YOLOv8
- Serves REST API for Flutter app
- Broadcasts detection events via WebSocket
"""

import cv2
import numpy as np
import requests
import threading
import json
import time
from datetime import datetime
from flask import Flask, Response, jsonify, request
from flask_cors import CORS
from ultralytics import YOLO
import logging

# Configuration
ESP32_IP = "10.153.99.158"  # Change to your ESP32 IP
ESP32_PORT = 80
STREAM_URL = f"http://{ESP32_IP}:{ESP32_PORT}/"
MODEL_PATH = "yolov8n.pt"  # Nano model for speed (fastest)

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Global state
current_frame = None
detection_results = []
is_streaming = False
lock = threading.Lock()

# Initialize YOLO model
print("Loading YOLOv8 model...")
model = YOLO(MODEL_PATH)
print("Model loaded!")

class StreamProcessor:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })

    def fetch_stream(self):
        """Fetch MJPEG stream from ESP32-CAM using OpenCV"""
        global current_frame, is_streaming

        stream_url = f"http://{ESP32_IP}:{ESP32_PORT}/"
        print(f"Connecting to ESP32 stream at {stream_url}")

        # OpenCV handles MJPEG streams much better than requests
        cap = cv2.VideoCapture(stream_url)
        cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)  # Minimize buffering

        if not cap.isOpened():
            print("Error: Cannot open stream")
            is_streaming = False
            return

        print("Stream connected!")
        is_streaming = True

        while True:
            ret, frame = cap.read()
            if ret:
                with lock:
                    current_frame = frame.copy()
            else:
                print("Frame read failed, retrying...")
                time.sleep(0.1)

        cap.release()

    def process_detection(self):
        """Process frames for object detection"""
        global detection_results

        while True:
            with lock:
                if current_frame is not None:
                    frame = current_frame.copy()
                else:
                    time.sleep(0.1)
                    continue

            # Run YOLO inference
            results = model(frame, verbose=False)

            # Parse detections
            detections = []
            for r in results:
                boxes = r.boxes
                for box in boxes:
                    x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
                    conf = float(box.conf[0])
                    cls = int(box.cls[0])
                    name = model.names[cls]

                    detections.append({
                        "class": name,
                        "confidence": round(conf, 2),
                        "bbox": [int(x1), int(y1), int(x2), int(y2)]
                    })

            with lock:
                detection_results = detections

            # Limit processing rate to reduce CPU load
            time.sleep(0.1)

# Start background threads
processor = StreamProcessor()
threading.Thread(target=processor.fetch_stream, daemon=True).start()
threading.Thread(target=processor.process_detection, daemon=True).start()

@app.route('/api/status')
def status():
    """Get server and ESP32 status"""
    return jsonify({
        "esp32_connected": is_streaming,
        "timestamp": datetime.now().isoformat(),
        "model": "YOLOv8n",
        "resolution": "640x480" if current_frame is not None else "N/A"
    })

@app.route('/api/detections')
def get_detections():
    """Get latest detection results"""
    with lock:
        return jsonify({
            "detections": detection_results,
            "count": len(detection_results),
            "timestamp": datetime.now().isoformat()
        })

@app.route('/api/stream')
def video_feed():
    """Proxy MJPEG stream with detection overlay"""
    def generate():
        while True:
            with lock:
                if current_frame is None:
                    time.sleep(0.1)
                    continue
                frame = current_frame.copy()

            # Draw detections on frame
            for det in detection_results:
                x1, y1, x2, y2 = det['bbox']
                label = f"{det['class']} {det['confidence']}"
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                cv2.putText(frame, label, (x1, y1-10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

            # Encode and yield
            ret, buffer = cv2.imencode('.jpg', frame)
            if ret:
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + buffer.tobytes() + b'\r\n')
            time.sleep(0.033)  # ~30 FPS

    return Response(generate(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/api/snapshot')
def snapshot():
    """Get current frame as JPEG"""
    with lock:
        if current_frame is None:
            return jsonify({"error": "No frame available"}), 503
        ret, buffer = cv2.imencode('.jpg', current_frame)
        if ret:
            return Response(buffer.tobytes(), mimetype='image/jpeg')
    return jsonify({"error": "Encoding failed"}), 500

@app.route('/api/control/<action>', methods=['POST'])
def control(action):
    """Control ESP32 (if you add control endpoints)"""
    # Example: Flash control, resolution change, etc.
    return jsonify({"status": "not implemented"})

if __name__ == '__main__':
    print("Starting ESP32-CAM AI Server...")
    print(f"Stream URL: {STREAM_URL}")
    # Run on all interfaces, port 5000
    app.run(host='0.0.0.0', port=5000, threaded=True, debug=False)

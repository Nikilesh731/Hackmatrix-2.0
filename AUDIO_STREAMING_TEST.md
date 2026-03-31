# Live Audio Streaming Test Guide

## Setup Complete ✅

### Files Changed:
- **Flutter Services:**
  - `lib/core/services/audio_service.dart` - Microphone recording with permissions
  - `lib/core/services/websocket_service.dart` - WebSocket streaming client
  - `lib/features/consultation/screens/consultation_screen.dart` - Integrated recording controls

- **Backend Gateway:**
  - `src/websocket/consultation.gateway.ts` - WebSocket event handlers
  - `src/websocket/websocket.module.ts` - Module configuration
  - `src/main.ts` - WebSocket server logging

## Event Names Used:
- `stream_start` - Initiates audio streaming session
- `audio_chunk` - Streams individual audio data chunks
- `stream_stop` - Ends streaming session

## Payload Format:

### Stream Start:
```json
{
  "event": "stream_start",
  "consultationId": "consultation-1234567890",
  "timestamp": "2026-03-29T19:44:39.123Z"
}
```

### Audio Chunk:
```json
{
  "event": "audio_chunk",
  "consultationId": "consultation-1234567890",
  "sequenceNumber": 1,
  "timestamp": "2026-03-29T19:44:39.456Z",
  "data": "base64-encoded-audio-data",
  "size": 1024
}
```

### Stream Stop:
```json
{
  "event": "stream_stop",
  "consultationId": "consultation-1234567890",
  "timestamp": "2026-03-29T19:44:45.789Z"
}
```

## How to Test:

### 1. Backend Status:
```bash
# Backend should be running on:
# HTTP: http://localhost:3000
# WebSocket: ws://localhost:3000
```

### 2. Flutter App:
```bash
# App should be running on:
# Web: http://localhost:8080
```

### 3. Testing Steps:
1. Navigate to Consultation Workspace in Flutter app
2. Click "Start Recording" button
3. Grant microphone permission when prompted
4. Speak into microphone - audio chunks will stream to backend
5. Click "Stop Recording" to end session

## Expected Backend Log Output:

```
LOG [ConsultationGateway] Client connected: abc123
LOG [ConsultationGateway] Stream started - Consultation: consultation-1234567890, Client: abc123, Timestamp: 2026-03-29T19:44:39.123Z
LOG [ConsultationGateway] Audio chunk received - Consultation: consultation-1234567890, Client: abc123, Sequence: 1, Size: 1024 bytes, Timestamp: 2026-03-29T19:44:39.456Z, Total chunks: 1
LOG [ConsultationGateway] Audio chunk received - Consultation: consultation-1234567890, Client: abc123, Sequence: 2, Size: 1024 bytes, Timestamp: 2026-03-29T19:44:39.789Z, Total chunks: 2
LOG [ConsultationGateway] Stream stopped - Consultation: consultation-1234567890, Client: abc123, Duration: 5666ms, Total chunks: 15, Timestamp: 2026-03-29T19:44:45.789Z
LOG [ConsultationGateway] Client disconnected: abc123
```

## Expected UI Behavior:
- Start Recording button disabled during recording
- Stop Recording button enabled during recording
- Red recording indicator appears in transcript panel
- Audio chunk entries appear in transcript area
- Recording state reflected in UI controls

## Technical Details:
- **Audio Format:** PCM 16-bit, 16kHz, mono
- **Chunk Size:** ~1024 bytes per chunk
- **WebSocket Protocol:** Socket.IO
- **Authentication:** Not implemented yet (for testing only)
- **Error Handling:** Basic error messages and reconnection logic

## Next Steps:
- Add transcription service integration
- Implement SOAP note generation
- Add authentication/authorization
- Add audio processing pipeline

# Consultation Session Identity Consistency Fix

## Problem Fixed
The consultation created from the dashboard returns an ID, but the audio streaming flow was generating a different consultation ID, causing inconsistency in the live streaming flow.

## Changes Made

### 1. Consultation Screen (`consultation_screen.dart`)
- **Added**: `late String _consultationId;` field
- **Updated**: `initState()` to receive consultation ID from navigation arguments
- **Added**: Debug log: `"🆔 Consultation ID received by consultation screen: $_consultationId"`
- **Updated**: `_initializeServices()` to use `_consultationId` instead of generating new one
- **Fallback**: Uses fallback ID only if consultation ID is truly missing

### 2. WebSocket Service (`websocket_service.dart`)
- **Added**: Debug log in `sendStreamStart()`: `"🆔 Consultation ID used in stream_start: $_consultationId"`
- **Added**: Debug log in `sendAudioChunk()`: `"🆔 Consultation ID used in audio_chunk: $_consultationId"`
- **Added**: Debug log in `sendStreamStop()`: `"🆔 Consultation ID used in stream_stop: $_consultationId"`

## Flow Consistency

### Before Fix:
1. Dashboard creates consultation → `consultation_12345`
2. Consultation screen generates new ID → `consultation-67890`
3. Streaming uses generated ID → `consultation-67890`
4. **Inconsistent IDs across the flow**

### After Fix:
1. Dashboard creates consultation → `consultation_12345`
2. Consultation screen receives same ID → `consultation_12345`
3. WebSocket connects with same ID → `consultation_12345`
4. Stream start uses same ID → `consultation_12345`
5. Audio chunks use same ID → `consultation_12345`
6. Stream stop uses same ID → `consultation_12345`
7. **Consistent ID throughout entire flow**

## Expected Debug Logs

When clicking "Start Consultation" and then starting recording:

```
🔥 Button clicked
🌐 Calling API...
🌐 URL: http://localhost:3000/api/consultations
📤 Payload: {patientId: test-patient-id}
✅ API Response: {id: consultation_1774804661226, ...}
🚀 Navigating to consultation screen
🆔 Consultation ID received by consultation screen: consultation_1774804661226
🆔 Consultation ID used in stream_start: consultation_1774804661226
🆔 Consultation ID used in audio_chunk: consultation_1774804661226
🆔 Consultation ID used in stream_stop: consultation_1774804661226
```

## Key Improvements

1. **Single Source of Truth**: Consultation ID created once in dashboard
2. **Consistent Flow**: Same ID used throughout streaming
3. **Debug Visibility**: Clear logs showing ID usage at each step
4. **Fallback Logic**: Only generates new ID if truly missing
5. **Minimal Changes**: No UI changes, no STT logic added

## Testing Verification

1. Click "Start Consultation" on dashboard
2. Observe navigation to consultation screen
3. Start recording
4. Check console logs for consistent consultation ID
5. Verify all streaming events use the same ID

The consultation session identity is now consistent across the entire live streaming flow.

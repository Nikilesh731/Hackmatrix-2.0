import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService {
  IO.Socket? _socket;
  bool _isConnected = false;
  String? _consultationId;
  Function(String)? _onStreamStopAck;

  bool get isConnected => _isConnected;
  String? get consultationId => _consultationId;

  void setOnStreamStopAckCallback(Function(String) callback) {
    _onStreamStopAck = callback;
  }

  Future<void> connect(String wsUrl, String consultationId) async {
    if (_isConnected) {
      await disconnect();
    }

    try {
      _consultationId = consultationId;
      
      // Create Socket.IO client
      _socket = IO.io(
        wsUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build(),
      );

      // Set up event listeners
      _socket!.onConnect((_) {
        _isConnected = true;
        print('WebSocket connected successfully');
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        print('WebSocket disconnected');
      });

      _socket!.onConnectError((error) {
        _isConnected = false;
        print('WebSocket connection error: $error');
      });

      // Listen for server acknowledgments
      _socket!.on('stream_started', (data) {
        print('Stream start acknowledged: $data');
      });

      _socket!.on('chunk_received', (data) {
        print('Chunk received acknowledged: $data');
      });

      _socket!.on('stream_stopped', (data) {
        print('Stream stop acknowledged: $data');
        
        // TRIGGER transcript fetch
        if (_onStreamStopAck != null && data['consultationId'] != null) {
          _onStreamStopAck!(data['consultationId']);
        }
      });

      // Connect to the server
      _socket!.connect();
      
      // Wait a moment for connection to establish
      await Future.delayed(const Duration(milliseconds: 500));
      
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
    _consultationId = null;
  }

  void sendStreamStart() {
    if (!_isConnected || _socket == null || _consultationId == null) {
      throw Exception('WebSocket not connected or consultation ID not set');
    }

    print(" Consultation ID used in stream_start: $_consultationId");

    final message = {
      'event': 'stream_start',
      'consultationId': _consultationId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _socket!.emit('stream_start', message);
  }

  void sendAudioChunk(Uint8List audioData, int sequenceNumber) {
    if (!_isConnected || _socket == null || _consultationId == null) {
      throw Exception('WebSocket not connected or consultation ID not set');
    }

    print(" Consultation ID used in audio_chunk: $_consultationId");

    final message = {
      'event': 'audio_chunk',
      'consultationId': _consultationId,
      'sequenceNumber': sequenceNumber,
      'timestamp': DateTime.now().toIso8601String(),
      'data': base64Encode(audioData),
      'size': audioData.length,
    };

    _socket!.emit('audio_chunk', message);
  }

  void sendStreamStop() {
    if (!_isConnected || _socket == null || _consultationId == null) {
      throw Exception('WebSocket not connected or consultation ID not set');
    }

    print(" Consultation ID used in stream_stop: $_consultationId");

    final message = {
      'event': 'stream_stop',
      'consultationId': _consultationId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _socket!.emit('stream_stop', message);
  }

  void dispose() {
    disconnect();
  }
}
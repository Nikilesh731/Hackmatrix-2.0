import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/websocket_service.dart';
import '../../../app/routes.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  bool _isRecording = false;
  bool _isConnecting = false;
  final ScrollController _transcriptController = ScrollController();
  final ScrollController _notesController = ScrollController();
  final List<String> _transcript = [];
  final List<String> _notes = [];
  
  final AudioService _audioService = AudioService();
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription? _audioSubscription;
  int _sequenceNumber = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize with a dummy consultation ID for testing
    final consultationId = 'consultation-${DateTime.now().millisecondsSinceEpoch}';
    const wsUrl = 'http://localhost:3000'; // Backend Socket.IO URL (use HTTP for Socket.IO)
    
    try {
      setState(() => _isConnecting = true);
      await _webSocketService.connect(wsUrl, consultationId);
      setState(() => _isConnecting = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WebSocket connected successfully')),
        );
      }
    } catch (e) {
      setState(() => _isConnecting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WebSocket connection failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Consultation Workspace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Content Area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout: stack vertically on small screens
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _buildTranscriptPanel(),
                      const SizedBox(height: 16),
                      _buildNotesPanel(),
                    ],
                  );
                } else {
                  // Side-by-side layout on larger screens
                  return Row(
                    children: [
                      Expanded(child: _buildTranscriptPanel()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildNotesPanel()),
                    ],
                  );
                }
              },
            ),
          ),
          
          // Bottom Control Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRecording ? null : _startRecording,
                  icon: const Icon(Icons.mic),
                  label: const Text('Start Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isRecording ? _stopRecording : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Icon(Icons.mic, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Live Transcript',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Connection status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _webSocketService.isConnected ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _webSocketService.isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _webSocketService.isConnected ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          fontSize: 10,
                          color: _webSocketService.isConnected ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isRecording) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _transcript.isEmpty
                  ? Text(
                      'Transcript will appear here...',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    )
                  : ListView.builder(
                      controller: _transcriptController,
                      itemCount: _transcript.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(_transcript[index]),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Icon(Icons.note_alt, color: Colors.purple.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Live Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _notes.isEmpty
                  ? Text(
                      'Notes will be generated...',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    )
                  : ListView.builder(
                      controller: _notesController,
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(_notes[index]),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _startRecording() async {
    if (!_webSocketService.isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WebSocket not connected')),
        );
      }
      return;
    }

    try {
      setState(() => _isRecording = true);
      
      // Send stream start event
      _webSocketService.sendStreamStart();
      
      // Start audio recording
      await _audioService.startRecording();
      
      // Reset sequence number
      _sequenceNumber = 0;
      
      // Listen to audio stream and send chunks
      _audioSubscription = _audioService.audioStream.listen(
        (audioData) {
          _sequenceNumber++;
          _webSocketService.sendAudioChunk(audioData, _sequenceNumber);
          
          // Add transcript placeholder for testing
          if (mounted) {
            setState(() {
              _transcript.add('Audio chunk #$_sequenceNumber received (${audioData.length} bytes)');
            });
            _scrollToBottom(_transcriptController);
          }
        },
        onError: (error) {
          _stopRecording();
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording started')),
        );
      }
    } catch (e) {
      setState(() => _isRecording = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  void _stopRecording() async {
    try {
      await _audioSubscription?.cancel();
      await _audioService.stopRecording();
      
      if (_webSocketService.isConnected) {
        _webSocketService.sendStreamStop();
      }
      
      setState(() => _isRecording = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording stopped')),
        );
      }
    } catch (e) {
      setState(() => _isRecording = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop recording: $e')),
        );
      }
    }
  }

  void _scrollToBottom(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    _audioService.dispose();
    _webSocketService.dispose();
    _transcriptController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
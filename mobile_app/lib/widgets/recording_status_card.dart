import 'package:flutter/material.dart';
import '../models/transcription_state.dart';

class RecordingStatusCard extends StatelessWidget {
  final TranscriptionState transcriptionState;
  final int recordingDuration;
  final String? errorMessage;

  const RecordingStatusCard({
    super.key,
    required this.transcriptionState,
    required this.recordingDuration,
    this.errorMessage,
  });

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
            if (transcriptionState == TranscriptionState.recording) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(recordingDuration),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (transcriptionState) {
      case TranscriptionState.idle:
        return Icons.mic_off;
      case TranscriptionState.connecting:
        return Icons.bluetooth_searching;
      case TranscriptionState.recording:
        return Icons.fiber_manual_record;
      case TranscriptionState.processing:
        return Icons.hourglass_empty;
      case TranscriptionState.completed:
        return Icons.check_circle;
      case TranscriptionState.error:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor() {
    switch (transcriptionState) {
      case TranscriptionState.idle:
        return Colors.grey;
      case TranscriptionState.connecting:
        return Colors.orange;
      case TranscriptionState.recording:
        return Colors.red;
      case TranscriptionState.processing:
        return Colors.blue;
      case TranscriptionState.completed:
        return Colors.green;
      case TranscriptionState.error:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (transcriptionState) {
      case TranscriptionState.idle:
        return 'Ready to record';
      case TranscriptionState.connecting:
        return 'Connecting...';
      case TranscriptionState.recording:
        return 'Recording';
      case TranscriptionState.processing:
        return 'Processing...';
      case TranscriptionState.completed:
        return 'Recording complete';
      case TranscriptionState.error:
        return 'Recording failed';
    }
  }
}

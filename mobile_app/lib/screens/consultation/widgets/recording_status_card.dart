import 'package:flutter/material.dart';

enum TranscriptionState {
  idle,
  connecting,
  recording,
  processing,
  completed,
  error,
}

class RecordingStatusCard extends StatelessWidget {
  final TranscriptionState transcriptionState;
  final bool isRecording;
  final bool isStopping;

  const RecordingStatusCard({
    super.key,
    required this.transcriptionState,
    required this.isRecording,
    required this.isStopping,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(),
                        ),
                      ),
                      Text(
                        _getStatusDescription(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isRecording || isStopping) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isStopping ? Colors.orange : Colors.red,
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
        return Icons.mic;
      case TranscriptionState.connecting:
        return Icons.bluetooth_connecting;
      case TranscriptionState.recording:
        return Icons.fiber_manual_record;
      case TranscriptionState.processing:
        return Icons.hourglass_empty;
      case TranscriptionState.completed:
        return Icons.check_circle;
      case TranscriptionState.error:
        return Icons.error;
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
        return 'Ready to Record';
      case TranscriptionState.connecting:
        return 'Connecting...';
      case TranscriptionState.recording:
        return 'Recording';
      case TranscriptionState.processing:
        return 'Processing';
      case TranscriptionState.completed:
        return 'Completed';
      case TranscriptionState.error:
        return 'Error';
    }
  }

  String _getStatusDescription() {
    switch (transcriptionState) {
      case TranscriptionState.idle:
        return 'Tap the microphone button to start recording';
      case TranscriptionState.connecting:
        return 'Establishing connection to transcription service';
      case TranscriptionState.recording:
        return 'Recording consultation... Tap to stop';
      case TranscriptionState.processing:
        return 'Processing transcription and generating clinical notes';
      case TranscriptionState.completed:
        return 'Transcription completed successfully';
      case TranscriptionState.error:
        return 'An error occurred during transcription';
    }
  }
}

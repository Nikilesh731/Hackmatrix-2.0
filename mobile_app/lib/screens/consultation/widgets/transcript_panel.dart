import 'package:flutter/material.dart';

class TranscriptPanel extends StatelessWidget {
  final String transcript;
  final bool isRecording;
  final bool isStopping;
  final String progressMessage;

  const TranscriptPanel({
    super.key,
    required this.transcript,
    required this.isRecording,
    required this.isStopping,
    required this.progressMessage,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = (isRecording || isStopping)
        ? (progressMessage.isEmpty ? 'Listening...' : progressMessage)
        : 'Transcript will appear here...';

    return Card(
      child: Container(
        constraints: const BoxConstraints(minHeight: 200),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.transcribe,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Live Transcript',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                const Spacer(),
                if (isRecording)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: transcript.isNotEmpty
                    ? SingleChildScrollView(
                        child: Text(
                          transcript,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          placeholder,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
              ),
            ),
            if (isRecording) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.7,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recording...',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

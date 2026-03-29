import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';

class LiveTranscriptScreen extends StatelessWidget {
  const LiveTranscriptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Live Transcript'),
      ),
      body: const Center(
        child: Text('Live Transcript - TODO: Implement real-time transcription'),
      ),
    );
  }
}
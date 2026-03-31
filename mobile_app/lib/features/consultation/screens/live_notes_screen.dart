import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';

class LiveNotesScreen extends StatelessWidget {
  const LiveNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Live Notes'),
      ),
      body: const Center(
        child: Text('Live Notes - TODO: Implement real-time SOAP generation'),
      ),
    );
  }
}
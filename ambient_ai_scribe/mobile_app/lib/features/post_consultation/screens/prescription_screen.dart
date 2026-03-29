import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';

class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Prescription'),
      ),
      body: const Center(
        child: Text('Prescription - TODO: Implement prescription management'),
      ),
    );
  }
}
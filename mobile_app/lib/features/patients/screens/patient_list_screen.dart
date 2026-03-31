import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: const Center(
        child: Text('Patient List - TODO: Implement patient management'),
      ),
    );
  }
}
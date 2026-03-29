import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';

class FhirPreviewScreen extends StatelessWidget {
  const FhirPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('FHIR Preview'),
      ),
      body: const Center(
        child: Text('FHIR Preview - TODO: Implement FHIR data preview'),
      ),
    );
  }
}
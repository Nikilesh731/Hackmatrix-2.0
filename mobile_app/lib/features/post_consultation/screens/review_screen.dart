import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Review'),
      ),
      body: const Center(
        child: Text('Review - TODO: Implement consultation review'),
      ),
    );
  }
}
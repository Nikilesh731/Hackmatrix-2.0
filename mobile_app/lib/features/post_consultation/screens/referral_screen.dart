import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Referral'),
      ),
      body: const Center(
        child: Text('Referral - TODO: Implement referral management'),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../app/routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isCreatingConsultation = false;

  Future<void> _startConsultation() async {
    setState(() {
      _isCreatingConsultation = true;
    });

    try {
      final apiService = ApiService();
      final consultationData = await apiService.createConsultation({
        'patientId': 'temp_patient_001',
        'sessionMetadata': {
          'startedAt': DateTime.now().toIso8601String(),
          'device': 'mobile_app'
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consultation created: ${consultationData['id']}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to consultation screen
        Navigator.pushNamed(context, AppRoutes.consultation);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create consultation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingConsultation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to Ambient AI Scribe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a new consultation session to begin AI-powered transcription and note generation',
                    style: TextStyle(
                      color: Colors.blue.shade50,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Main Action Button
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isCreatingConsultation ? null : _startConsultation,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_filled,
                          size: 48,
                          color: _isCreatingConsultation 
                              ? Colors.grey.shade400 
                              : Colors.green.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isCreatingConsultation 
                              ? 'Creating Session...' 
                              : 'Start Consultation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isCreatingConsultation 
                                ? Colors.grey.shade600 
                                : Colors.green.shade700,
                          ),
                        ),
                        if (_isCreatingConsultation)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.history, color: Colors.grey.shade600),
                        const SizedBox(height: 4),
                        Text(
                          '0',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          'Past Sessions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_done, color: Colors.grey.shade600),
                        const SizedBox(height: 4),
                        Text(
                          'Connected',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
                          ),
                        ),
                        Text(
                          'API Status',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
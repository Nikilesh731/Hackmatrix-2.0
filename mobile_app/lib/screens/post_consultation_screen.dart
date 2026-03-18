import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/consultation.dart';
import '../models/doctor_profile.dart';
import '../services/auth_service.dart';
import '../services/consultation_repository.dart';
import '../widgets/soap_display_widget.dart';
import '../widgets/prescription_widget.dart';

class PostConsultationScreen extends StatefulWidget {
  const PostConsultationScreen({super.key});

  @override
  State<PostConsultationScreen> createState() => _PostConsultationScreenState();
}

class _PostConsultationScreenState extends State<PostConsultationScreen> {
  Consultation? _consultation;
  DoctorProfile? _doctorProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConsultationData();
  }

  Future<void> _loadConsultationData() async {
    try {
      // Get consultation ID from route parameters
      final uri = GoRouterState.of(context).uri;
      final consultationId = uri.queryParameters['consultationId'];

      if (consultationId == null) {
        throw Exception('Consultation ID not found');
      }

      final doctorProfile = await AuthService.getCurrentDoctorProfile();
      final consultation = await ConsultationRepository.getConsultationById(consultationId);

      if (mounted) {
        setState(() {
          _doctorProfile = doctorProfile;
          _consultation = consultation;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load consultation: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Summary'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          if (_consultation != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // TODO: Implement PDF download
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF download coming soon')),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _consultation == null
                  ? const Center(
                      child: Text('Consultation not found'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Patient and Doctor Info
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Consultation Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.person, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Doctor: ${_doctorProfile?.fullName ?? 'Unknown'}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Date: ${_consultation!.createdAt.day}/${_consultation!.createdAt.month}/${_consultation!.createdAt.year}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Transcript Section
                          if (_consultation!.finalTranscript != null && _consultation!.finalTranscript!.isNotEmpty)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transcript',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: Text(_consultation!.finalTranscript!),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // SOAP Notes Section
                          SoapDisplayWidget(consultation: _consultation!),
                          const SizedBox(height: 16),

                          // Prescription Section
                          PrescriptionWidget(consultation: _consultation!),
                        ],
                      ),
                    ),
    );
  }
}

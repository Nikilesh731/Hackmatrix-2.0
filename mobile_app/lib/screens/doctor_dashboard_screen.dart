import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/doctor_profile.dart';
import '../models/patient.dart';
import '../models/patient_queue_item.dart';
import '../services/auth_service.dart';
import '../services/patient_repository.dart';
import '../services/supabase_service.dart';
import '../widgets/patient_queue_card.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  DoctorProfile? _doctorProfile;
  List<PatientQueueItem> _queueItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    PatientRepository.initialize();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final doctorProfile = await AuthService.getCurrentDoctorProfile();
      if (doctorProfile == null) {
        throw Exception('Doctor profile not found');
      }

      final queueItems = await PatientRepository.getActiveQueueForDoctor(doctorProfile.id);

      if (mounted) {
        setState(() {
          _doctorProfile = doctorProfile;
          _queueItems = queueItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load dashboard: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createSampleData() async {
    if (_doctorProfile == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await PatientRepository.createSamplePatientsAndQueue(_doctorProfile!.id);
      
      // Refresh queue after creating sample data
      await _refreshQueue();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample patients created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create sample data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshQueue() async {
    if (_doctorProfile == null) return;
    
    try {
      final queueItems = await PatientRepository.getActiveQueueForDoctor(_doctorProfile!.id);
      
      if (mounted) {
        setState(() {
          _queueItems = queueItems;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh queue: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${_doctorProfile?.fullName ?? 'Doctor'}'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshQueue,
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _createSampleData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.signOut();
              if (mounted) {
                context.go('/auth');
              }
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
              : _queueItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No patients in queue',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add sample patients',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshQueue,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _queueItems.length,
                        itemBuilder: (context, index) {
                          return PatientQueueCard(
                            queueItem: _queueItems[index],
                            onStartConsultation: () {
                              // Navigate to consultation screen
                              context.go('/consultation?queueId=${_queueItems[index].id}');
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

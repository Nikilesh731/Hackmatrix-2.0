import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/doctor_profile.dart';
import '../models/patient.dart';
import '../models/patient_queue_item.dart';
import '../models/transcription_state.dart';
import '../services/auth_service.dart';
import '../services/audio_service.dart';
import '../services/transcription_service.dart';
import '../services/soap_service.dart';
import '../services/fhir/fhir_builder.dart';
import '../services/fhir/fhir_models.dart';
import '../services/sarvam_streaming_service.dart';
import '../services/transcription/transcript_display_formatter.dart';
import '../services/soap/soap_models.dart';
import '../widgets/recording_status_card.dart';
import '../widgets/transcript_panel.dart';
import '../widgets/soap_panel.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  DoctorProfile? _doctorProfile;
  Patient? _patient;
  PatientQueueItem? _queueItem;
  String _transcript = '';
  String _displayTranscript = '';
  SOAPNotes? _soapNotes;
  FhirBundle? _fhirBundle;
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  String? _errorMessage;
  TranscriptionState _transcriptionState = TranscriptionState.idle;
  String _progressMessage = '';
  
  StreamSubscription<String>? _transcriptionSubscription;
  Timer? _soapDebounce;
  int _soapRequestVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadConsultationData();
  }

  @override
  void dispose() {
    _soapDebounce?.cancel();
    _transcriptionSubscription?.cancel();
    _recordingTimer?.cancel();
    _stopRecording();
    super.dispose();
  }

  Future<void> _loadConsultationData() async {
    try {
      final doctorProfile = await AuthService.getCurrentDoctorProfile();
      if (doctorProfile == null) {
        throw Exception('Doctor profile not found');
      }

      // Get queue item and patient from navigation parameters
      final args = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (args != null) {
        final queueItem = args['queueItem'] as PatientQueueItem?;
        final patient = args['patient'] as Patient?;
        
        setState(() {
          _doctorProfile = doctorProfile;
          _queueItem = queueItem;
          _patient = patient ?? queueItem?.patient;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load consultation data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      setState(() {
        _isRecording = true;
        _transcriptionState = TranscriptionState.connecting;
        _progressMessage = 'Initializing...';
        _errorMessage = null;
      });

      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) throw Exception('Not authenticated');

      await AudioService.initialize();
      await SarvamStreamingService.initialize();

      _transcriptionSubscription = SarvamStreamingService
          .startTranscription(session.accessToken)
          .listen(_handleTranscriptionChunk);

      setState(() {
        _transcriptionState = TranscriptionState.recording;
        _progressMessage = 'Recording...';
      });

      _startRecordingTimer();
    } catch (e) {
      setState(() {
        _isRecording = false;
        _transcriptionState = TranscriptionState.error;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() {
        _transcriptionState = TranscriptionState.processing;
        _progressMessage = 'Processing...';
        _errorMessage = null;
      });

      _recordingTimer?.cancel();
      await _transcriptionSubscription?.cancel();
      await SarvamStreamingService.stopTranscription();
      await AudioService.dispose();

      setState(() {
        _isRecording = false;
        _transcriptionState = TranscriptionState.completed;
        _progressMessage = 'Processing complete';
      });

      _handleTranscriptionComplete();
    } catch (e) {
      setState(() {
        _isRecording = false;
        _transcriptionState = TranscriptionState.error;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  void _handleTranscriptionChunk(String chunk) {
    setState(() {
      _transcript += chunk;
      _displayTranscript = TranscriptDisplayFormatter.formatForDisplay(_transcript);
    });

    _scheduleSoapRefresh();
  }

  void _handleTranscriptionComplete() {
    if (_transcript.isNotEmpty) {
      _refreshSoapNow();
    }
  }

  void _scheduleSoapRefresh() {
    _soapDebounce?.cancel();
    final requestVersion = ++_soapRequestVersion;

    _soapDebounce = Timer(const Duration(milliseconds: 600), () async {
      final notes = await SOAPService.generateSOAPFromTranscript(_transcript);

      if (!mounted || requestVersion != _soapRequestVersion) return;

      setState(() {
        _soapNotes = notes;
      });

      await _generateFhir(notes);
    });
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingDuration = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingDuration++;
        });
      }
    });
  }

  Future<void> _refreshSoapNow() async {
    final notes = await SOAPService.generateSOAPFromTranscript(_transcript);
    
    if (!mounted) return;
    
    setState(() {
      _soapNotes = notes;
    });
    
    await _generateFhir(notes);
  }

  Future<void> _generateFhir(SOAPNotes notes) async {
    final bundle = FhirBuilder.buildBundle(notes);

    if (!mounted) return;

    setState(() {
      _fhirBundle = bundle;
    });
  }

  void _updateSOAPNotes(SOAPNotes updatedNotes) {
    setState(() {
      _soapNotes = updatedNotes;
    });
    _generateFhir(updatedNotes);
  }

  void _navigateToPostConsultation() {
    if (_soapNotes == null || _fhirBundle == null) return;

    context.push('/post-consultation', extra: {
      'consultation': _soapNotes,
      'patient': _patient,
      'doctorProfile': _doctorProfile,
      'queueItem': _queueItem,
      'fhirBundle': _fhirBundle,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_patient != null ? 'Consultation - ${_patient!.fullName}' : 'Ambient AI Scribe'),
        actions: [
          if (_soapNotes != null && _fhirBundle != null)
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _navigateToPostConsultation,
              tooltip: 'Continue to Post-Consultation',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_patient != null) _buildPatientInfo(),
              if (_patient != null) const SizedBox(height: 16),
              
              RecordingStatusCard(
                transcriptionState: _transcriptionState,
                recordingDuration: _recordingDuration,
                errorMessage: _errorMessage,
              ),
              const SizedBox(height: 16),

              TranscriptPanel(
                liveTranscript: _displayTranscript,
                finalTranscript: _transcript,
                transcriptionState: _transcriptionState,
              ),
              const SizedBox(height: 16),

              if (_soapNotes != null) ...[
                SoapPanel(
                  soapNotes: _soapNotes,
                  isLoading: _transcriptionState == TranscriptionState.processing,
                ),
                const SizedBox(height: 16),
              ],

              if (_fhirBundle != null) ...[
                _buildFhirPanel(),
                const SizedBox(height: 16),
              ],

              _buildRecordingControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    if (_patient == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _patient!.fullName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_patient!.age != null) ...[
              Text('Age: ${_patient!.age}'),
              const SizedBox(height: 4),
            ],
            if (_patient!.gender != null) ...[
              Text('Gender: ${_patient!.gender}'),
              const SizedBox(height: 4),
            ],
            if (_patient!.phone != null) ...[
              Text('Phone: ${_patient!.phone}'),
              const SizedBox(height: 4),
            ],
            if (_patient!.bloodGroup != null) ...[
              Text('Blood Group: ${_patient!.bloodGroup}'),
              const SizedBox(height: 4),
            ],
            if (_patient!.allergies != null) ...[
              Text('Allergies: ${_patient!.allergies}'),
              const SizedBox(height: 4),
            ],
            if (_patient!.chronicConditions != null) ...[
              Text('Chronic Conditions: ${_patient!.chronicConditions}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFhirPanel() {
    if (_fhirBundle == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FHIR Bundle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Entries: ${_fhirBundle!.entry.length}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ..._fhirBundle!.entry.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${entry.resource.resourceType}',
                style: const TextStyle(fontSize: 14),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingControls() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          GestureDetector(
            onTap: _transcriptionState == TranscriptionState.processing ? null : _toggleRecording,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording ? Colors.red : Colors.blue,
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),

          if (_soapNotes != null && _fhirBundle != null && !_isRecording)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _navigateToPostConsultation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Continue to Post-Consultation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _completeConsultation() async {
    try {
      // Create consultation record
      final consultationData = {
        'doctor_id': _doctorProfile!.id,
        'patient_id': _patient!.id,
        'queue_item_id': _queueItem?.id,
        'status': 'completed',
        'final_transcript': _transcript,
        'soap_subjective': _soapNotes?.subjective,
        'soap_objective': _soapNotes?.objective,
        'soap_assessment': _soapNotes?.assessment,
        'soap_plan': _soapNotes?.plan,
        'structured_extraction': _soapNotes?.toJson(),
        'ended_at': DateTime.now().toIso8601String(),
      };

      final response = await Supabase.instance.client
          .from('consultations')
          .insert(consultationData)
          .select('id')
          .single();

      // Update queue item status
      if (_queueItem != null) {
        await Supabase.instance.client
            .from('patient_queue')
            .update({'queue_status': 'completed'})
            .eq('id', _queueItem!.id);
      }

      // Navigate to post-consultation screen
      if (mounted) {
        context.go('/post-consultation?consultationId=${response['id']}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete consultation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToPostConsultation() async {
    if (_soapNotes == null || _fhirBundle == null) return;

    await _completeConsultation();
  }
}

import '../models/patient.dart';
import '../models/patient_queue_item.dart';
import 'supabase_service.dart';

class PatientRepository {
  static bool _isInitialized = false;

  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  static Future<List<Patient>> getAllPatients() async {
    if (!_isInitialized) {
      throw Exception('PatientRepository not initialized');
    }

    final response = await SupabaseService.client
        .from('patients')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Patient.fromJson(json))
        .toList();
  }

  static Future<Patient?> getPatientById(String patientId) async {
    if (!_isInitialized) return null;

    final response = await SupabaseService.client
        .from('patients')
        .select()
        .eq('id', patientId)
        .maybeSingle();

    if (response == null) return null;
    return Patient.fromJson(response);
  }

  static Future<void> createSamplePatientsAndQueue(String doctorId) async {
    if (!_isInitialized) return;

    try {
      print('Creating sample patients and queue for doctor: $doctorId');
      
      // Create sample patients if they don't exist
      final samplePatients = [
        {
          'full_name': 'Amit Kumar',
          'age': 35,
          'gender': 'male',
          'phone': '+91-9876543212',
          'address': '123 Main St, Delhi',
          'blood_group': 'B+',
          'allergies': 'Penicillin',
          'chronic_conditions': 'Hypertension',
          'notes': 'Regular patient'
        },
        {
          'full_name': 'Sunita Devi',
          'age': 28,
          'gender': 'female',
          'phone': '+91-9876543213',
          'address': '456 Park Ave, Delhi',
          'blood_group': 'O+',
          'allergies': 'None',
          'chronic_conditions': 'None',
          'notes': 'First visit'
        },
        {
          'full_name': 'Ramesh Singh',
          'age': 45,
          'gender': 'male',
          'phone': '+91-9876543214',
          'address': '789 Market Rd, Delhi',
          'blood_group': 'A+',
          'allergies': 'Sulfa drugs',
          'chronic_conditions': 'Diabetes Type 2',
          'notes': 'Follow-up needed'
        }
      ];

      final patientIds = <String>[];
      
      // Insert patients
      for (final patient in samplePatients) {
        try {
          final response = await SupabaseService.client
              .from('patients')
              .insert(patient)
              .select('id')
              .single();
          patientIds.add(response['id'] as String);
          print('Created patient: ${patient['full_name']} with ID: ${response['id']}');
        } catch (e) {
          // Patient might already exist, try to get existing
          try {
            final existing = await SupabaseService.client
                .from('patients')
                .select('id')
                .eq('full_name', patient['full_name'] as String)
                .single();
            patientIds.add(existing['id'] as String);
            print('Found existing patient: ${patient['full_name']} with ID: ${existing['id']}');
          } catch (e2) {
            print('Failed to create or find patient: ${patient['full_name']} - $e2');
          }
        }
      }

      print('Patient IDs collected: $patientIds');

      // Create queue items with better error handling
      final queueItems = [
        {'patient_id': patientIds[0], 'priority_label': 'medium', 'reason_for_visit': 'Fever and cough for 3 days'},
        {'patient_id': patientIds[1], 'priority_label': 'low', 'reason_for_visit': 'Routine health checkup'},
        {'patient_id': patientIds[2], 'priority_label': 'high', 'reason_for_visit': 'Diabetes followup'},
      ];

      int successCount = 0;
      for (int i = 0; i < queueItems.length && i < patientIds.length; i++) {
        final queueItem = {
          ...queueItems[i],
          'assigned_doctor_id': doctorId,
          'queue_status': 'waiting',
          'token_number': i + 1,
        };
        
        try {
          await SupabaseService.client
              .from('patient_queue')
              .insert(queueItem);
          successCount++;
          print('Created queue item ${i + 1} for patient ${patientIds[i]}');
        } catch (e) {
          print('Failed to create queue item: $e');
          print('Queue item data: $queueItem');
        }
      }
      
      print('Sample patients and queue items created successfully: $successCount/${queueItems.length} queue items');
    } catch (e) {
      print('Error creating sample data: $e');
    }
  }

  static Future<List<PatientQueueItem>> getActiveQueueForDoctor(String doctorId) async {
    if (!_isInitialized) {
      throw Exception('PatientRepository not initialized');
    }

    try {
      // First try to get waiting queue items
      final waitingResponse = await SupabaseService.client
          .from('patient_queue')
          .select('''
            *,
            patients (
              id,
              full_name,
              age,
              gender,
              phone,
              address,
              blood_group,
              allergies,
              chronic_conditions,
              notes
            )
          ''')
          .eq('assigned_doctor_id', doctorId)
          .eq('queue_status', 'waiting')
          .order('priority_label', ascending: false)
          .order('token_number', ascending: true)
          .order('created_at', ascending: true);

      // Then get in_progress queue items
      final inProgressResponse = await SupabaseService.client
          .from('patient_queue')
          .select('''
            *,
            patients (
              id,
              full_name,
              age,
              gender,
              phone,
              address,
              blood_group,
              allergies,
              chronic_conditions,
              notes
            )
          ''')
          .eq('assigned_doctor_id', doctorId)
          .eq('queue_status', 'in_progress')
          .order('priority_label', ascending: false)
          .order('token_number', ascending: true)
          .order('created_at', ascending: true);

      // Combine both lists
      final allItems = [...waitingResponse, ...inProgressResponse];
      
      print('Queue response length: ${allItems.length}');
      return allItems
          .map((json) => PatientQueueItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error in getActiveQueueForDoctor: $e');
      print('Doctor ID: $doctorId');
      rethrow;
    }
  }

  static Future<PatientQueueItem?> getQueueItemById(String queueItemId) async {
    if (!_isInitialized) return null;

    try {
      final response = await SupabaseService.client
          .from('patient_queue')
          .select('''
            *,
            patients (
              id,
              full_name,
              age,
              gender,
              phone,
              address,
              blood_group,
              allergies,
              chronic_conditions,
              notes
            )
          ''')
          .eq('id', queueItemId)
          .maybeSingle();

      if (response == null) return null;
      return PatientQueueItem.fromJson(response);
    } catch (e) {
      print('Error in getQueueItemById: $e');
      print('Queue Item ID: $queueItemId');
      rethrow;
    }
  }

  static Future<PatientQueueItem> startConsultation(String queueItemId) async {
    if (!_isInitialized) {
      throw Exception('PatientRepository not initialized');
    }

    final response = await SupabaseService.client
        .from('patient_queue')
        .update({
          'queue_status': 'in_progress',
          'started_at': DateTime.now().toIso8601String(),
        })
        .eq('id', queueItemId)
        .select()
        .single();

    return PatientQueueItem.fromJson(response);
  }

  static Future<PatientQueueItem> completeQueueItem(String queueItemId) async {
    if (!_isInitialized) {
      throw Exception('PatientRepository not initialized');
    }

    final response = await SupabaseService.client
        .from('patient_queue')
        .update({
          'queue_status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', queueItemId)
        .select()
        .single();

    return PatientQueueItem.fromJson(response);
  }
}

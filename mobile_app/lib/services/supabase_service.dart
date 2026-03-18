import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  static SupabaseClient get client => _client;

  // Patients
  static Future<List<Map<String, dynamic>>> getPatients() async {
    final response = await _client.from('patients').select().order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> getPatient(String id) async {
    final response = await _client.from('patients').select().eq('id', id).single();
    return response;
  }

  static Future<Map<String, dynamic>> createPatient(Map<String, dynamic> patient) async {
    final response = await _client.from('patients').insert(patient).select().single();
    return response;
  }

  static Future<Map<String, dynamic>> updatePatient(String id, Map<String, dynamic> updates) async {
    final response = await _client.from('patients').update(updates).eq('id', id).select().single();
    return response;
  }

  static Future<void> deletePatient(String id) async {
    await _client.from('patients').delete().eq('id', id);
  }

  // Doctor Profiles
  static Future<Map<String, dynamic>?> getCurrentDoctorProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('doctor_profiles')
          .select()
          .eq('auth_id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> createDoctorProfile(Map<String, dynamic> profile) async {
    final response = await _client.from('doctor_profiles').insert(profile).select().single();
    return response;
  }

  static Future<Map<String, dynamic>> updateDoctorProfile(String id, Map<String, dynamic> updates) async {
    final response = await _client.from('doctor_profiles').update(updates).eq('id', id).select().single();
    return response;
  }

  // Patient Queue
  static Future<List<Map<String, dynamic>>> getPatientQueue(String doctorId) async {
    final response = await _client
        .from('patient_queue')
        .select('''
          *,
          patients:patient_id (
            id,
            full_name,
            age,
            gender,
            phone,
            blood_group,
            allergies,
            chronic_conditions
          )
        ''')
        .eq('assigned_doctor_id', doctorId)
        .or('queue_status.eq.waiting,queue_status.eq.in_progress')
        .order('priority_label', ascending: false)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>> addToQueue(Map<String, dynamic> queueItem) async {
    final response = await _client.from('patient_queue').insert(queueItem).select().single();
    return response;
  }

  static Future<Map<String, dynamic>> updateQueueStatus(String id, String status) async {
    final response = await _client
        .from('patient_queue')
        .update({
          'queue_status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  static Future<void> removeFromQueue(String id) async {
    await _client.from('patient_queue').delete().eq('id', id);
  }

  // Consultations
  static Future<List<Map<String, dynamic>>> getConsultations(String doctorId) async {
    final response = await _client
        .from('consultations')
        .select('''
          *,
          patients:patient_id (
            id,
            full_name,
            age,
            gender,
            phone
          )
        ''')
        .eq('doctor_id', doctorId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>> createConsultation(Map<String, dynamic> consultation) async {
    final response = await _client.from('consultations').insert(consultation).select().single();
    return response;
  }

  static Future<Map<String, dynamic>> updateConsultation(String id, Map<String, dynamic> updates) async {
    final response = await _client.from('consultations').update(updates).eq('id', id).select().single();
    return response;
  }

  static Future<Map<String, dynamic>> completeConsultation(String id, Map<String, dynamic> finalData) async {
    final response = await _client
        .from('consultations')
        .update({
          ...finalData,
          'status': 'completed',
          'ended_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  // Specialist Directory
  static Future<List<Map<String, dynamic>>> getSpecialists({bool activeOnly = true}) async {
    final query = _client.from('specialist_directory').select();
    
    if (activeOnly) {
      query.eq('is_active', true);
    }
    
    final response = await query.order('doctor_name');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> searchSpecialists(String query) async {
    final response = await _client
        .from('specialist_directory')
        .select()
        .eq('is_active', true)
        .or('doctor_name.ilike.%$query%,specialty.ilike.%$query%,department.ilike.%$query%')
        .order('doctor_name');
    return List<Map<String, dynamic>>.from(response);
  }

  // Real-time subscriptions (simplified for now)
  static Stream<List<Map<String, dynamic>>> subscribeToQueue(String doctorId) {
    // For now, return a simple stream that can be enhanced later
    return Stream.value([]);
  }

  static Stream<Map<String, dynamic>> subscribeToConsultation(String consultationId) {
    return _client
        .from('consultations')
        .stream(primaryKey: ['id'])
        .eq('id', consultationId)
        .limit(1)
        .map((event) => event.first);
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

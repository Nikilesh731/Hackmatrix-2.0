import '../models/consultation.dart';
import 'supabase_service.dart';

class ConsultationRepository {
  static Future<Consultation> createConsultation({
    required String doctorId,
    required String patientId,
    String? queueItemId,
  }) async {
    final response = await SupabaseService.client
        .from('consultations')
        .insert({
          'doctor_id': doctorId,
          'patient_id': patientId,
          'queue_item_id': queueItemId,
          'status': 'in_progress',
          'started_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return Consultation.fromJson(response);
  }

  static Future<Consultation> updateConsultationTranscript({
    required String consultationId,
    required String transcript,
  }) async {
    final response = await SupabaseService.client
        .from('consultations')
        .update({
          'final_transcript': transcript,
        })
        .eq('id', consultationId)
        .select()
        .single();

    return Consultation.fromJson(response);
  }

  static Future<Consultation> updateConsultationSoapNotes({
    required String consultationId,
    String? subjective,
    String? objective,
    String? assessment,
    String? plan,
  }) async {
    final response = await SupabaseService.client
        .from('consultations')
        .update({
          'soap_subjective': subjective,
          'soap_objective': objective,
          'soap_assessment': assessment,
          'soap_plan': plan,
        })
        .eq('id', consultationId)
        .select()
        .single();

    return Consultation.fromJson(response);
  }

  static Future<Consultation> updateConsultationMedications({
    required String consultationId,
    required List<Map<String, dynamic>> medications,
  }) async {
    final response = await SupabaseService.client
        .from('consultations')
        .update({
          'confirmed_medications': medications,
        })
        .eq('id', consultationId)
        .select()
        .single();

    return Consultation.fromJson(response);
  }

  static Future<Consultation?> getConsultationById(String consultationId) async {
    final response = await SupabaseService.client
        .from('consultations')
        .select()
        .eq('id', consultationId)
        .maybeSingle();

    if (response == null) return null;
    return Consultation.fromJson(response);
  }

  static Future<List<Consultation>> getConsultationsByDoctor(String doctorId) async {
    final response = await SupabaseService.client
        .from('consultations')
        .select()
        .eq('doctor_id', doctorId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Consultation.fromJson(json))
        .toList();
  }

  static Future<Consultation> completeConsultation(String consultationId) async {
    final response = await SupabaseService.client
        .from('consultations')
        .update({
          'status': 'completed',
          'ended_at': DateTime.now().toIso8601String(),
        })
        .eq('id', consultationId)
        .select()
        .single();

    return Consultation.fromJson(response);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/doctor_profile.dart';
import '../services/supabase_service.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;

  static Stream<Session?> get authStateChanges => _client.auth.onAuthStateChange.map((event) => event.session);

  static bool get isAuthenticated => currentUser != null;

  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  static Future<DoctorProfile?> getCurrentDoctorProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('doctor_profiles')
          .select()
          .eq('auth_id', user.id)
          .maybeSingle();

      if (response == null) return null;
      return DoctorProfile.fromJson(response);
    } catch (e) {
      print('Error fetching doctor profile: $e');
      return null;
    }
  }

  static Future<DoctorProfile> createDoctorProfile({
    required String fullName,
    required String email,
    required String phone,
    required String specialization,
    required String hospitalName,
    required String registrationNumber,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final profileData = {
      'auth_id': userId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'hospital_name': hospitalName,
      'registration_number': registrationNumber,
    };

    final response = await SupabaseService.createDoctorProfile(profileData);
    return DoctorProfile.fromJson(response);
  }

  static Future<DoctorProfile> updateDoctorProfile({
    required String id,
    String? fullName,
    String? email,
    String? phone,
    String? specialization,
    String? hospitalName,
    String? registrationNumber,
  }) async {
    final updates = <String, dynamic>{};
    
    if (fullName != null) updates['full_name'] = fullName;
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;
    if (specialization != null) updates['specialization'] = specialization;
    if (hospitalName != null) updates['hospital_name'] = hospitalName;
    if (registrationNumber != null) updates['registration_number'] = registrationNumber;

    final response = await SupabaseService.updateDoctorProfile(id, updates);
    return DoctorProfile.fromJson(response);
  }

  static Future<bool> isProfileComplete() async {
    final profile = await getCurrentDoctorProfile();
    return profile != null;
  }

  static Future<String?> getUserRole() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('doctor_profiles')
          .select('specialization')
          .eq('auth_id', userId)
          .single();
      
      return response['specialization'] as String?;
    } catch (e) {
      return null;
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/doctor_profile.dart';

class AuthService {
  static Stream<Session?> get authStateChanges => Supabase.instance.client.auth.onAuthStateChange;

  static Future<DoctorProfile?> getCurrentDoctorProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await Supabase.instance.client
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

  static Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}

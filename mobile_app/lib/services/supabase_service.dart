import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  static late SupabaseClient _client;

  static SupabaseClient get client => _client;

  static void initialize() {
    _client = Supabase.instance.client;
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

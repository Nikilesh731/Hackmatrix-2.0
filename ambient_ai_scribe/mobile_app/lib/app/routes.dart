import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/consultation/screens/consultation_screen.dart';
import '../features/post_consultation/screens/review_screen.dart';
import '../features/post_consultation/screens/fhir_preview_screen.dart';
import '../features/post_consultation/screens/prescription_screen.dart';
import '../features/post_consultation/screens/referral_screen.dart';
import '../features/patients/screens/patient_list_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String consultation = '/consultation';
  static const String review = '/review';
  static const String fhirPreview = '/review/fhir';
  static const String prescription = '/review/prescription';
  static const String referral = '/review/referral';
  static const String patients = '/patients';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    consultation: (context) => const ConsultationScreen(),
    review: (context) => const ReviewScreen(),
    fhirPreview: (context) => const FhirPreviewScreen(),
    prescription: (context) => const PrescriptionScreen(),
    referral: (context) => const ReferralScreen(),
    patients: (context) => const PatientListScreen(),
  };

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    // TODO: Implement dynamic routing with parameters
    return null;
  }
}
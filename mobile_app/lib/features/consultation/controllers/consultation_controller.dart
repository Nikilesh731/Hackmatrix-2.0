import 'package:flutter/material.dart';
import '../repositories/consultation_repository.dart';

// TODO: Implement consultation state management
class ConsultationController extends ChangeNotifier {
  final ConsultationRepository _repository = ConsultationRepository();
  
  String _transcript = '';
  String get transcript => _transcript;
  
  bool _mounted = true;
  
  void startConsultation() {
    // TODO: Implement consultation start logic
  }
  
  void pauseConsultation() {
    // TODO: Implement consultation pause logic
  }
  
  void endConsultation() {
    // TODO: Implement consultation end logic
  }
  
  Future<void> fetchFinalTranscript(String consultationId) async {
    try {
      final result = await _repository.getTranscript(consultationId);

      if (result != null && result.isNotEmpty) {
        if (!_mounted) return;

        _transcript = result;
        notifyListeners();

        _generateSoapFromTranscript(result);
      }
    } catch (e) {
      print("Transcript fetch failed: $e");
    }
  }
  
  void _generateSoapFromTranscript(String transcript) {
    // TODO: Implement SOAP generation from transcript
    print("Generating SOAP from transcript: $transcript");
  }
  
  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}
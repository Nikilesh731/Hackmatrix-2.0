import 'package:flutter/material.dart';
import '../../../services/soap/soap_models.dart';

class SoapPanel extends StatelessWidget {
  final SOAPNotes? soapNotes;
  final bool isRecording;
  final bool isStopping;

  const SoapPanel({
    super.key,
    required this.soapNotes,
    required this.isRecording,
    required this.isStopping,
  });

  @override
  Widget build(BuildContext context) {
    if (soapNotes == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.medical_information,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'SOAP Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isRecording || isStopping 
                    ? 'Generating SOAP notes from transcript...'
                    : 'SOAP notes will appear here after recording',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_alt,
                  color: Colors.green[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'SOAP Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                if (isRecording || isStopping) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Updating...',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            
            // Subjective
            _buildSection(
              'Subjective (S)',
              soapNotes!.subjective,
              Icons.person_outline,
            ),
            const SizedBox(height: 12),
            
            // Objective
            _buildSection(
              'Objective (O)',
              soapNotes!.objective,
              Icons.monitor_heart,
            ),
            const SizedBox(height: 12),
            
            // Assessment
            _buildSection(
              'Assessment (A)',
              soapNotes!.assessment,
              Icons.psychology,
            ),
            const SizedBox(height: 12),
            
            // Plan
            _buildSection(
              'Plan (P)',
              soapNotes!.plan,
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.blue[600],
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content.isNotEmpty ? content : 'No information available',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: content.isNotEmpty ? Colors.black87 : Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../models/consultation.dart';

class SoapDisplayWidget extends StatelessWidget {
  final Consultation consultation;

  const SoapDisplayWidget({
    super.key,
    required this.consultation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SOAP Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 16),
            
            // Subjective
            if (consultation.soapSubjective != null)
              _buildSoapSection(
                'Subjective (S)',
                consultation.soapSubjective!,
                Icons.person_outline,
              ),
            
            if (consultation.soapSubjective != null)
              const SizedBox(height: 12),
            
            // Objective
            if (consultation.soapObjective != null)
              _buildSoapSection(
                'Objective (O)',
                consultation.soapObjective!,
                Icons.monitor_heart,
              ),
            
            if (consultation.soapObjective != null)
              const SizedBox(height: 12),
            
            // Assessment
            if (consultation.soapAssessment != null)
              _buildSoapSection(
                'Assessment (A)',
                consultation.soapAssessment!,
                Icons.analytics,
              ),
            
            if (consultation.soapAssessment != null)
              const SizedBox(height: 12),
            
            // Plan
            if (consultation.soapPlan != null)
              _buildSoapSection(
                'Plan (P)',
                consultation.soapPlan!,
                Icons.note_alt,
              ),
            
            if (consultation.soapSubjective == null &&
                consultation.soapObjective == null &&
                consultation.soapAssessment == null &&
                consultation.soapPlan == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No SOAP notes available yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoapSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

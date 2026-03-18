import 'package:flutter/material.dart';
import '../services/soap/soap_models.dart';

class SoapPanel extends StatelessWidget {
  final SOAPNotes? soapNotes;
  final bool isLoading;

  const SoapPanel({
    super.key,
    this.soapNotes,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (soapNotes != null) ...[
              _buildSoapSection('Subjective', soapNotes!.subjective, Icons.person_outline),
              const SizedBox(height: 12),
              _buildSoapSection('Objective', soapNotes!.objective, Icons.monitor_heart),
              const SizedBox(height: 12),
              _buildSoapSection('Assessment', soapNotes!.assessment, Icons.analytics),
              const SizedBox(height: 12),
              _buildSoapSection('Plan', soapNotes!.plan, Icons.note_alt),
            ] else ...[
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

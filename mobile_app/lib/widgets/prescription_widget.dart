import 'package:flutter/material.dart';
import '../models/consultation.dart';

class PrescriptionWidget extends StatefulWidget {
  final Consultation consultation;

  const PrescriptionWidget({
    super.key,
    required this.consultation,
  });

  @override
  State<PrescriptionWidget> createState() => _PrescriptionWidgetState();
}

class _PrescriptionWidgetState extends State<PrescriptionWidget> {
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void dispose() {
    _medicationController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _addMedication() {
    if (_medicationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter medication name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final medication = {
      'medication': _medicationController.text.trim(),
      'dosage': _dosageController.text.trim().isEmpty ? 'As prescribed' : _dosageController.text.trim(),
      'frequency': _frequencyController.text.trim().isEmpty ? 'As prescribed' : _frequencyController.text.trim(),
      'duration': _durationController.text.trim().isEmpty ? 'As prescribed' : _durationController.text.trim(),
      'instructions': _instructionsController.text.trim(),
      'prescribedAt': DateTime.now().toIso8601String(),
      'prescribedBy': 'Doctor', // This should come from doctor profile
    };

    final medications = List<Map<String, dynamic>>.from(widget.consultation.confirmedMedications ?? []);
    medications.add(medication);

    // Update consultation
    _updateMedications(medications);

    // Clear form
    _medicationController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _durationController.clear();
    _instructionsController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medication added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _updateMedications(List<Map<String, dynamic>> medications) async {
    try {
      // This would update the consultation in the database
      // For now, we'll just update the local state
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add medication: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeMedication(int index) {
    final medications = List<Map<String, dynamic>>.from(widget.consultation.confirmedMedications ?? []);
    medications.removeAt(index);
    _updateMedications(medications);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medication removed'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medications = widget.consultation.confirmedMedications ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prescription',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 16),

            // Add Medication Form
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Medication',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _medicationController,
                    decoration: const InputDecoration(
                      labelText: 'Medication Name *',
                      prefixIcon: Icon(Icons.medication),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dosageController,
                          decoration: const InputDecoration(
                            labelText: 'Dosage',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _frequencyController,
                          decoration: const InputDecoration(
                            labelText: 'Frequency',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          decoration: const InputDecoration(
                            labelText: 'Duration',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _instructionsController,
                          decoration: const InputDecoration(
                            labelText: 'Instructions',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addMedication,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Medication'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Medications List
            if (medications.isNotEmpty) ...[
              Text(
                'Current Medications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 8),
              ...medications.asMap().entries.map((entry) {
                final index = entry.key;
                final medication = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              medication['medication'] ?? 'Unknown Medication',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeMedication(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (medication['dosage'] != null)
                        Text('Dosage: ${medication['dosage']}'),
                      if (medication['frequency'] != null)
                        Text('Frequency: ${medication['frequency']}'),
                      if (medication['duration'] != null)
                        Text('Duration: ${medication['duration']}'),
                      if (medication['instructions'] != null && medication['instructions'].isNotEmpty)
                        Text('Instructions: ${medication['instructions']}'),
                    ],
                  ),
                );
              }).toList(),
            ],

            if (medications.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No medications prescribed yet',
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
}

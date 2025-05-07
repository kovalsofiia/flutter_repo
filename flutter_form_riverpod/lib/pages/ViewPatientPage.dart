import 'package:flutter/material.dart';
import 'package:flutter_form/models/patient.dart';

class ViewPatientPage extends StatelessWidget {
  final Patient patient;
  final VoidCallback onDelete;
  final ValueChanged<Patient> onEdit;
  const ViewPatientPage({
    super.key,
    required this.patient,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Перегляд одного пацієнта")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ПІБ: ${patient.name}', style: const TextStyle(fontSize: 18)),
          Text(
            'Рік народження: ${patient.birthYear.toString()}',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'Причина відвідування: ${patient.reason}',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'Лікар: ${patient.doctor}',
            style: const TextStyle(fontSize: 18),
          ),
          Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    onDelete();
                    Navigator.pop(context); // Повернутися до списку
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.delete),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

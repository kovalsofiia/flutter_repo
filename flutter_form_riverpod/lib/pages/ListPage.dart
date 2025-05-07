import 'package:flutter/material.dart';
import 'package:flutter_form/models/patient.dart';
import 'package:flutter_form/pages/AddPatientPage.dart';
import 'package:flutter_form/pages/ViewPatientPage.dart';
import 'package:flutter_form/pages/CartPage.dart';
import 'package:flutter_form/providers/cartProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListPatientPage extends StatefulWidget {
  const ListPatientPage({super.key});

  @override
  State<ListPatientPage> createState() => _ListPatientPageState();
}

class _ListPatientPageState extends State<ListPatientPage> {
  final List<Patient> _patients = [];

  void addPatient(Patient patient) {
    setState(() {
      _patients.add(patient);
    });
  }

  void updatePatient(int index, Patient updatedPatient) {
    setState(() {
      _patients[index] = updatedPatient;
    });
  }

  void deletePatient(int index) {
    setState(() {
      _patients.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Сторінка перегляду списку"),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final cartState = ref.watch(cartProvider);
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartPage()),
                      );
                    },
                  ),
                  if (cartState.doctorsChosen.isNotEmpty)
                    Positioned(
                      right: 0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          cartState.doctorsChosen.length.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      body:
          _patients.isEmpty
              ? const Center(child: Text('Список порожній'))
              : ListView.builder(
                itemCount: _patients.length,
                itemBuilder: (context, index) {
                  final patient = _patients[index];
                  return ListTile(
                    title: Text(patient.name),
                    subtitle: Text(
                      'Лікар та причина: ${patient.doctor} - ${patient.reason}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deletePatient(index),
                    ),
                    onTap: () {
                      // навігатор перехід
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ViewPatientPage(
                                patient: patient,
                                onDelete: () => deletePatient(index),
                                onEdit:
                                    (updatedPatient) =>
                                        updatePatient(index, updatedPatient),
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
      // кнопочка додавання обєкту
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPatient = await Navigator.push<Patient>(
            context,
            MaterialPageRoute(builder: (context) => const AddPatientPage()),
          );
          if (newPatient != null) {
            addPatient(newPatient);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form/models/doctor.dart';
import 'package:flutter_form/models/patient.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key, this.patient});
  final Patient? patient;

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  // для форми ключ
  final _formKey = GlobalKey<FormState>();
  // контролери для полей, які потім можна валідувати.
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();
  // поля потрібні для вибору значення
  String? _reason;
  Doctor? _doctor;

  late Future<List<Doctor>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _readJson();
    if (widget.patient != null) {
      _nameController.text = widget.patient!.name;
      _yearController.text = widget.patient!.birthYear.toString();
      _reason = widget.patient!.reason;
      // _doctor
    }
  }

  Future<List<Doctor>> _readJson() async {
    final String response = await rootBundle.loadString('assets/doctors.json');
    final data = await json.decode(response);
    final List<dynamic> doctorsData = data["doctors"] as List;
    return doctorsData.map((item) => Doctor.fromJson(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Форма додавання пацієнта")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'ПІБ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ПІБ не може бути порожнім';
                  }
                  final words = value.trim().split(' ');
                  if (words.length < 2) {
                    return 'Будь ласка, введіть повне ім\'я та прізвище';
                  }
                  if (!RegExp(r'^[a-zA-Zа-яА-ЯіїєІЇЄ\s]+$').hasMatch(value)) {
                    return 'ПІБ може містити лише літери та пробіли';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Рік народження'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Рік не може бути порожнім';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year <= 1930 || year >= 2027) {
                    return 'Рік має бути більше за 1930 і менше або рівне 2026';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text("Причина запису"),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Огляд'),
                      value: 'Огляд',
                      groupValue: _reason,
                      onChanged: (value) => setState(() => _reason = value),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Розшифровка аналізів'),
                      value: 'Розшифровка аналізів',
                      groupValue: _reason,
                      onChanged: (value) => setState(() => _reason = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Doctor>>(
                future: _doctorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text(
                      'Помилка завантаження лікарів: ${snapshot.error}',
                    );
                  } else if (snapshot.hasData) {
                    final doctors = snapshot.data!;
                    // If editing, find the doctor matching the patient's doctor
                    if (widget.patient != null && _doctor == null) {
                      _doctor = doctors.firstWhere(
                        (doctor) =>
                            doctor.specialization == widget.patient!.doctor,
                        orElse: () => doctors[0],
                      );
                    }
                    return DropdownButtonFormField<Doctor>(
                      decoration: const InputDecoration(labelText: 'Лікар'),
                      value: _doctor,
                      items:
                          doctors
                              .map(
                                (doctor) => DropdownMenuItem<Doctor>(
                                  value: doctor,
                                  child: Text(
                                    '${doctor.name} - ${doctor.specialization}',
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (Doctor? newValue) {
                        setState(() {
                          _doctor = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Виберіть лікаря';
                        }
                        return null;
                      },
                    );
                  } else {
                    return const Text('Немає даних про лікарів');
                  }
                },
              ),

              // DropdownButtonFormField<String>(
              //   decoration: const InputDecoration(labelText: 'Лікар'),
              //   value: _doctor,
              //   items: const [
              //     DropdownMenuItem(
              //       value: 'Лікар ендокринолог',
              //       child: Text('Лікар ендокринолог'),
              //     ),
              //     DropdownMenuItem(
              //       value: 'Лікар терапевт',
              //       child: Text('Лікар терапевт'),
              //     ),
              //     DropdownMenuItem(
              //       value: 'Лікар узд',
              //       child: Text('Лікар узд'),
              //     ),
              //   ],
              //   onChanged: (value) => setState(() => _doctor = value),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Виберіть лікаря';
              //     }
              //     return null;
              //   },
              // ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(
                      context,
                      Patient(
                        name: _nameController.text,
                        birthYear: int.parse(_yearController.text),
                        reason: _reason!,
                        doctor: _doctor!.specialization,
                      ),
                    );
                  }
                },
                child: const Text('Зберегти'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}

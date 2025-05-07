import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form/models/doctor.dart';
import 'package:flutter_form/models/patient.dart';
import 'package:flutter_form/providers/cartProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPatientPage extends ConsumerWidget {
  // Змінено на ConsumerWidget
  const AddPatientPage({super.key, this.patient});
  final Patient? patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Додано WidgetRef
    return _AddPatientPageStateWidget(patient: patient);
  }
}

class _AddPatientPageStateWidget extends StatefulWidget {
  const _AddPatientPageStateWidget({this.patient});
  final Patient? patient;

  @override
  State<_AddPatientPageStateWidget> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<_AddPatientPageStateWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();
  String? _reason = 'Огляд';
  Doctor? _doctor;
  // дописала тут
  Doctor? _previousDoctor;

  late Future<List<Doctor>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _readJson();
    if (widget.patient != null) {
      _nameController.text = widget.patient!.name;
      _yearController.text = widget.patient!.birthYear.toString();
      _reason = widget.patient!.reason;
      // дописала тут
      _doctorsFuture.then((doctors) {
        _previousDoctor = doctors.firstWhere(
          (doctor) => doctor.specialization == widget.patient!.doctor,
          orElse: () => doctors[0],
        );
      });
    }
  }

  Future<List<Doctor>> _readJson() async {
    final String response = await rootBundle.loadString('assets/doctors.json');
    final data = await json.decode(response);
    final List<dynamic> doctorsData = data["doctors"] as List;
    return doctorsData.map((item) => Doctor.fromJson(item)).toList();
  }

  // Функція для створення модифікованого лікаря з правильною ціною яку використовуємо
  Doctor getModifiedDoctor(Doctor doctor, String reason) {
    final price =
        reason == 'Розшифровка аналізів' ? doctor.price - 200 : doctor.price;
    return Doctor(
      name: doctor.name,
      specialization: doctor.specialization,
      price:
          price < 0
              ? 0
              : price, // щоб ціна не стала відємною, то просто запишемо звичайну ціну
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      // Використовуємо Consumer для доступу до ref
      builder: (context, ref, child) {
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
                      if (!RegExp(
                        r'^[a-zA-Zа-яА-ЯіїєІЇЄ\s]+$',
                      ).hasMatch(value)) {
                        return 'ПІБ може містити лише літери та пробіли';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Рік народження',
                    ),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Додаємо лікаря до корзини
                        if (_doctor != null && _reason != null) {
                          // Отримуємо модифікованого лікаря з правильною ціною
                          final modifiedDoctor = getModifiedDoctor(
                            _doctor!,
                            _reason!,
                          );
                          // Видаляємо попереднього лікаря, якщо він існує
                          if (_previousDoctor != null &&
                              (_previousDoctor != _doctor ||
                                  widget.patient!.reason != _reason)) {
                            final previousModifiedDoctor = getModifiedDoctor(
                              _previousDoctor!,
                              widget.patient!.reason,
                            );
                            ref
                                .read(cartProvider.notifier)
                                .removeItem(previousModifiedDoctor);
                          }
                          // Додаємо модифікованого лікаря, якщо його ще немає
                          if (!ref
                              .read(cartProvider)
                              .doctorsChosen
                              .contains(modifiedDoctor)) {
                            ref
                                .read(cartProvider.notifier)
                                .addItem(modifiedDoctor);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Лікар ${modifiedDoctor.name} доданий до корзини',
                                ),
                              ),
                            );
                          }
                        }
                        // Повертаємо створеного/оновленого пацієнта
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
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}

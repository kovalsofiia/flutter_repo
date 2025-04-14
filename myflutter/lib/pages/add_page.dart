import 'package:flutter/material.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/api/db_op.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController elevationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController imagePathController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isPopular = false;

  final dbOperations = DbOperations.fromSettings();

  String? _selectedRegion;
  String? _selectedDistrict;
  List<String> _regions = [];
  List<String> _districts = [];
  Map<String, List<String>> _regionDistricts = {};

  final String nameLabel = 'Name';
  final String elevationLabel = 'Elevation (m)';
  final String regionLabel = 'Select Region';
  final String districtLabel = 'Select District';
  final String imagePathLabel = 'Image Path (optional)';
  final String descriptionLabel = 'Description';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/regions_ukr.json',
      );
      final jsonData = json.decode(jsonString);
      final regionsList = jsonData['regions'] as List;

      setState(() {
        _regions =
            regionsList
                .map<String>((region) => region['name'].toString())
                .toList();
        _regionDistricts = Map.fromIterable(
          regionsList,
          key: (region) => region['name'].toString(),
          value:
              (region) =>
                  (region['districts'] as List)
                      .map<String>((district) => district.toString())
                      .toList(),
        );
      });
    } catch (e) {
      print('Error loading JSON: $e');
    }
  }

  void _updateDistricts(String regionName) {
    setState(() {
      _districts = _regionDistricts[regionName] ?? [];
      _selectedDistrict = null;
    });
  }

  void addPeak() async {
    if (_formKey.currentState!.validate()) {
      Peak peak = Peak(
        name: nameController.text,
        elevation: int.parse(elevationController.text),
        location: '$_selectedRegion, $_selectedDistrict',
        description: descriptionController.text,
        imagePath: imagePathController.text,
        isPopular: isPopular,
      );
      await dbOperations.addElement(peak.toMap());
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Peak'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nameLabel),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(elevationLabel),
              TextFormField(
                controller: elevationController,
                decoration: InputDecoration(
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter elevation';
                  }
                  final intElevation = int.tryParse(value);

                  if (intElevation == null) {
                    return 'Please enter a valid number';
                  }
                  if (intElevation <= 0) {
                    return 'Elevation must be greater than 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(regionLabel),
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRegion = newValue;
                    if (newValue != null) {
                      _updateDistricts(newValue);
                    } else {
                      _districts.clear();
                      _selectedDistrict = null;
                    }
                  });
                },
                items:
                    _regions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                decoration: InputDecoration(
                  labelText: regionLabel,
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a region';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(districtLabel),
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                onChanged:
                    _districts.isEmpty
                        ? null
                        : (String? newValue) {
                          setState(() {
                            _selectedDistrict = newValue;
                          });
                        },
                items:
                    _districts.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                decoration: InputDecoration(
                  labelText: districtLabel,
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a district';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(imagePathLabel),
              TextField(controller: imagePathController),
              SizedBox(height: 16),
              Text(descriptionLabel),
              TextField(controller: descriptionController),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Is Popular'),
                  Switch(
                    value: isPopular,
                    onChanged: (value) {
                      setState(() {
                        isPopular = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  child: const Text('Add Peak'),
                  onPressed: () {
                    addPeak();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

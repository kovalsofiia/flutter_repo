import 'package:flutter/material.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/api/db_op.dart';

class EditPage extends StatefulWidget {
  final Peak peak;

  const EditPage({Key? key, required this.peak}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController elevationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController imagePathController = TextEditingController();
  bool isPopular = false;

  final dbOperations = DbOperations.fromSettings();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.peak.name;
    elevationController.text = widget.peak.elevation.toString();
    locationController.text = widget.peak.location;
    descriptionController.text = widget.peak.description;
    imagePathController.text = widget.peak.imagePath ?? ''; // Обробка null
    isPopular = widget.peak.isPopular;
  }

  void updatePeak() async {
    Peak peak = Peak(
      key: widget.peak.key,
      name: nameController.text,
      elevation: int.parse(elevationController.text),
      location: locationController.text,
      description: descriptionController.text,
      imagePath: imagePathController.text, // Дозволяємо null
      isPopular: isPopular,
      timestamp: widget.peak.timestamp, // Keep the old timestamp for updates
      // Update timestamp on update
    );
    await dbOperations.updateElement(peak.key!, peak.toMap());
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Peak'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: elevationController,
              decoration: const InputDecoration(labelText: 'Elevation (m)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: imagePathController,
              decoration: const InputDecoration(
                labelText: 'Image Path (optional)',
              ), // Зроблено optional
            ),
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
            ElevatedButton(
              child: const Text('Update Peak'),
              onPressed: () {
                updatePeak();
              },
            ),
          ],
        ),
      ),
    );
  }
}

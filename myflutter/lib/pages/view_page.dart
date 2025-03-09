import 'package:flutter/material.dart';
import 'package:myflutter/models/peak.dart';

class DetailPage extends StatelessWidget {
  final Peak peak;

  DetailPage({required this.peak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(peak.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            peak.imagePath != null && peak.imagePath!.isNotEmpty
                ? Image.network(peak.imagePath!, height: 300, fit: BoxFit.cover)
                : Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                  ),
                ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Name: ${peak.name}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Elevation: ${peak.elevation} m',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Location: ${peak.location}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Description: ${peak.description}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Popular: ${peak.isPopular ? 'Yes' : 'No'}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

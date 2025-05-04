import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/api/db_op.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPage extends StatefulWidget {
  final String
  peakId; // Змінюємо на peakId замість передачі всього об'єкта Peak
  final VoidCallback onLoginNeeded;

  const DetailPage({
    Key? key,
    required this.peakId,
    required this.onLoginNeeded,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final dbOperations = DbOperations.fromSettings();

  Widget buildInfoRow({
    required IconData icon,
    required String label,
    String? value,
    bool bold = false,
  }) {
    final hasValue = value != null && value.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasValue ? value : label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: hasValue ? Colors.black : Colors.grey,
                fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = authSnapshot.data != null;

        // Використовуємо StreamBuilder для отримання даних про вершину
        return StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('peaks')
                  .doc(widget.peakId)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text('Peak not found')),
              );
            }

            // Отримуємо дані вершини
            final peakData = snapshot.data!.data() as Map<String, dynamic>;
            final peak = Peak.fromMap({'key': widget.peakId, ...peakData});

            return Scaffold(
              appBar: AppBar(title: Text(peak.name)),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Stack(
                      children: [
                        peak.imagePath != null && peak.imagePath!.isNotEmpty
                            ? Image.network(
                              peak.imagePath!,
                              height: 300,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 300,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              },
                            )
                            : Container(
                              height: 300,
                              color: Colors.grey[300],
                              child: Center(
                                child: Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: StreamBuilder<bool>(
                            stream: dbOperations.isFavourite(widget.peakId),
                            initialData: false,
                            builder: (context, snapshot) {
                              final isFavourite = snapshot.data ?? false;
                              return IconButton(
                                icon: Icon(
                                  isFavourite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      isFavourite
                                          ? Colors.red[400]
                                          : Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  if (!isLoggedIn) {
                                    widget.onLoginNeeded();
                                    return;
                                  }
                                  try {
                                    await dbOperations.toggleFavourite(
                                      widget.peakId,
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error toggling favourite: $e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          buildInfoRow(
                            icon: Icons.terrain,
                            label: 'Name',
                            value: peak.name,
                            bold: true,
                          ),
                          buildInfoRow(
                            icon: Icons.height,
                            label: 'Elevation',
                            value: '${peak.elevation} m',
                          ),
                          buildInfoRow(
                            icon: Icons.location_on,
                            label: 'Location',
                            value: peak.location,
                          ),
                          buildInfoRow(
                            icon: Icons.description,
                            label: 'Description',
                            value: peak.description,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                peak.isPopular ? Icons.star : Icons.star_border,
                                size: 24,
                                color:
                                    peak.isPopular
                                        ? Colors.yellow
                                        : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                peak.isPopular ? 'Popular peak' : 'Not popular',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

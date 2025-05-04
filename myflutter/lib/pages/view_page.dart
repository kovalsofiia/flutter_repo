import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/api/db_op.dart';

class DetailPage extends StatefulWidget {
  final Peak peak;
  final VoidCallback onLoginNeeded;

  const DetailPage({Key? key, required this.peak, required this.onLoginNeeded})
    : super(key: key);

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
    // Використовуємо StreamBuilder для відстеження стану авторизації
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = snapshot.data != null;

        return Scaffold(
          appBar: AppBar(title: Text(widget.peak.name)),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Stack(
                  children: [
                    widget.peak.imagePath != null &&
                            widget.peak.imagePath!.isNotEmpty
                        ? Image.network(
                          widget.peak.imagePath!,
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
                    // Іконка сердечка у верхньому правому куті
                    Positioned(
                      top: 8,
                      right: 8,
                      child: StreamBuilder<bool>(
                        stream: dbOperations.isFavourite(widget.peak.key!),
                        initialData: false,
                        builder: (context, snapshot) {
                          final isFavourite = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              isFavourite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  isFavourite ? Colors.red[400] : Colors.grey,
                              size: 20,
                            ),
                            onPressed: () async {
                              if (!isLoggedIn) {
                                widget.onLoginNeeded();
                                return;
                              }
                              try {
                                await dbOperations.toggleFavourite(
                                  widget.peak.key!,
                                );
                                // Оновлення UI не потрібне, бо StreamBuilder автоматично реагує
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
                        value: widget.peak.name,
                        bold: true,
                      ),
                      buildInfoRow(
                        icon: Icons.height,
                        label: 'Elevation',
                        value: '${widget.peak.elevation} m',
                      ),
                      buildInfoRow(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: widget.peak.location,
                      ),
                      buildInfoRow(
                        icon: Icons.description,
                        label: 'Description',
                        value: widget.peak.description,
                      ),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            widget.peak.isPopular
                                ? Icons.star
                                : Icons.star_border,
                            size: 24,
                            color:
                                widget.peak.isPopular
                                    ? Colors.yellow
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.peak.isPopular
                                ? 'Popular peak'
                                : 'Not popular',
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
  }
}

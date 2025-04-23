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
                      Text(
                        'Name: ${widget.peak.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Elevation: ${widget.peak.elevation} m',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location: ${widget.peak.location}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Description: ${widget.peak.description}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Popular: ${widget.peak.isPopular ? 'Yes' : 'No'}',
                        style: const TextStyle(fontSize: 16),
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

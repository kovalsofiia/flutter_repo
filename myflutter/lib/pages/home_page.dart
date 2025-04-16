import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/api/db_op.dart';
import 'package:myflutter/pages/view_page.dart'; // Імпортуємо DetailPage

class HomePage extends StatefulWidget {
  final VoidCallback onLoginNeeded;
  const HomePage({Key? key, required this.onLoginNeeded}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Peak> peaks = [];
  List<Peak> popularPeaks = [];
  final dbOperations = DbOperations.fromSettings();
  late bool isLoading;
  String? _sortValue;
  bool showPopular = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    Future.wait([loadPeaks(), loadPopularPeaks()]).then((_) {
      setState(() {
        isLoading = false;
        showPopular = false;
      });
    });
  }

  Future<void> loadPopularPeaks() async {
    List<Map<String, dynamic>> data = await dbOperations.loadByPopularTag();
    List<Peak> loadedPeaks = data.map((map) => Peak.fromMap(map)).toList();
    setState(() {
      popularPeaks = loadedPeaks;
      sortPopularPeaks();
      isLoading = false;
    });
  }

  Future<List<Peak>> loadPeaks() async {
    List<Map<String, dynamic>> data =
        await dbOperations.readCollectionWithKeys();
    List<Peak> loadedPeaks = data.map((map) => Peak.fromMap(map)).toList();
    setState(() {
      peaks = loadedPeaks;
      sortPeaks();
      isLoading = false;
      showPopular = false;
    });
    return loadedPeaks;
  }

  void navigateToViewPage(Peak peak) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                DetailPage(peak: peak, onLoginNeeded: widget.onLoginNeeded),
      ),
    );
    if (result is bool && result == true) {
      loadPeaks();
    }
  }

  void toggleView() {
    setState(() {
      showPopular = !showPopular;
    });
  }

  void sortPeaks() {
    switch (_sortValue) {
      case 'a-z':
        peaks.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'z-a':
        peaks.sort((a, b) => b.name.compareTo(a.name));
        break;
      case '0-1':
        peaks.sort((a, b) => a.elevation.compareTo(b.elevation));
        break;
      case '1-0':
        peaks.sort((a, b) => b.elevation.compareTo(a.elevation));
        break;
      default:
        peaks.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    }
  }

  void sortPopularPeaks() {
    switch (_sortValue) {
      case 'a-z':
        popularPeaks.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'z-a':
        popularPeaks.sort((a, b) => b.name.compareTo(a.name));
        break;
      case '0-1':
        popularPeaks.sort((a, b) => a.elevation.compareTo(b.elevation));
        break;
      case '1-0':
        popularPeaks.sort((a, b) => b.elevation.compareTo(a.elevation));
        break;
      default:
        popularPeaks.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            loadPeaks();
          },
          child: const Text('Peaks'),
        ),
        actions: [
          DropdownButton<String>(
            value: _sortValue,
            hint: const Text('Sort'),
            items: const [
              DropdownMenuItem(child: Text('A-Z'), value: 'a-z'),
              DropdownMenuItem(child: Text('Z-A'), value: 'z-a'),
              DropdownMenuItem(
                child: Text('From highest to lowest'),
                value: '1-0',
              ),
              DropdownMenuItem(
                child: Text('From lowest to highest'),
                value: '0-1',
              ),
            ],
            onChanged: (value) {
              setState(() {
                _sortValue = value;
                sortPeaks();
                sortPopularPeaks();
              });
            },
          ),
        ],
      ),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: showPopular ? popularPeaks.length : peaks.length,
                  itemBuilder: (context, index) {
                    final Peak peak =
                        showPopular ? popularPeaks[index] : peaks[index];
                    return Card(
                      child: InkWell(
                        onTap: () => navigateToViewPage(peak),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  // Зображення
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:
                                        peak.imagePath != null &&
                                                peak.imagePath!.isNotEmpty
                                            ? Image.network(
                                              peak.imagePath!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Image.asset(
                                                  'assets/default.png',
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            )
                                            : Image.asset(
                                              'assets/default.png',
                                              fit: BoxFit.cover,
                                            ),
                                  ),
                                  // Зірочка та сердечко у верхньому правому куті
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (peak.isPopular)
                                          Icon(
                                            Icons.star,
                                            color: Colors.yellow[700],
                                            size: 20,
                                          ),
                                        const SizedBox(width: 8),
                                        StreamBuilder<bool>(
                                          stream: dbOperations.isFavourite(
                                            peak.key!,
                                          ),
                                          initialData: false,
                                          builder: (context, snapshot) {
                                            final isFavourite =
                                                snapshot.data ?? false;
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
                                              onPressed: () {
                                                if (!isLoggedIn) {
                                                  widget.onLoginNeeded();
                                                  return;
                                                }
                                                dbOperations.toggleFavourite(
                                                  peak.key!,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Назва та висота
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    peak.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${peak.elevation} m',
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: toggleView,
        label: Text(showPopular ? 'View All Peaks' : 'View Popular Peaks'),
        icon: Icon(showPopular ? Icons.list : Icons.star),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

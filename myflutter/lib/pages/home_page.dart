import 'package:flutter/material.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/api/db_op.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
      isLoading = false;
    });
  }

  Future<List<Peak>> loadPeaks() async {
    List<Map<String, dynamic>> data =
        await dbOperations.readCollectionWithKeys();
    List<Peak> loadedPeaks = data.map((map) => Peak.fromMap(map)).toList();
    loadedPeaks.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    setState(() {
      isLoading = false;
      peaks = loadedPeaks;
      showPopular = false; // Set showPopular to false
    });
    return loadedPeaks;
  }

  void navigateToViewPage(Peak peak) async {
    var result = await Navigator.pushNamed(context, '/view', arguments: peak);
    if (result is bool && result == true) {
      loadPeaks();
    }
  }

  void loadPopular() async {
    await loadPopularPeaks();
    setState(() {
      showPopular = true; // Set showPopular to true
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            loadPeaks();
          },
          child: Text('Peaks'),
        ),
        actions: [
          DropdownButton<String>(
            value: _sortValue,
            hint: Text('Sort'),
            items: [
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
                  default: // Handle default sorting here
                    peaks.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
                }
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
                    childAspectRatio: 0.8, // Adjust as needed
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
                              child: Padding(
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
                            ),
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
                                  if (peak.isPopular)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4.0),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.yellow[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Popular',
                                        style: TextStyle(fontSize: 10),
                                      ),
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
        onPressed: () {
          loadPopular();
        },
        label: const Text('View Popular Peaks'),
        icon: const Icon(Icons.star),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

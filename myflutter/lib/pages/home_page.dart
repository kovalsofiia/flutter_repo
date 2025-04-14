import 'package:flutter/material.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/api/db_op.dart';
// import 'package:myflutter/pages/add_page.dart';
// import 'package:myflutter/pages/edit_page.dart';

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

  void removePeak(Peak peak) async {
    await dbOperations.removeElement(peak.key!);
    setState(() {
      peaks.remove(peak);
    });
  }

  // void navigateToAddPage() async {
  //   bool result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const AddPage()),
  //   );
  //   if (result == true) {
  //     loadPeaks();
  //   }
  // }

  // void navigateToEditPage(Peak peak) async {
  //   bool result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => EditPage(peak: peak)),
  //   );
  //   if (result == true) {
  //     loadPeaks();
  //   }
  // }

  void navigateToAddPage() async {
    var result = await Navigator.pushNamed(context, '/add');
    if (result is bool && result == true) {
      loadPeaks();
    }
  }

  void navigateToEditPage(Peak peak) async {
    var result = await Navigator.pushNamed(context, '/edit', arguments: peak);
    if (result is bool && result == true) {
      loadPeaks();
    }
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
          ElevatedButton(
            onPressed: () {
              loadPopular();
            },
            child: Text('View Popular Peaks'),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              navigateToAddPage();
            },
          ),
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
                ? CircularProgressIndicator()
                : ListView.builder(
                  itemCount: showPopular ? popularPeaks.length : peaks.length,
                  itemBuilder: (context, index) {
                    Peak peak =
                        showPopular ? popularPeaks[index] : peaks[index];
                    return Dismissible(
                      key: Key(peak.key!),
                      onDismissed: (direction) {
                        removePeak(peak);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Peak removed')),
                        );
                      },
                      child: ListTile(
                        leading:
                            peak.imagePath != null && peak.imagePath!.isNotEmpty
                                ? Image.network(peak.imagePath!)
                                : Image.asset('assets/default.png'),
                        title: Text(peak.name),
                        subtitle: Text('${peak.elevation} m, ${peak.location}'),
                        onTap: () {
                          navigateToViewPage(peak);
                        },
                        trailing: Row(
                          // Wrap trailing widgets in a Row
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (peak
                                .isPopular) // Conditionally show the yellow box
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text("Popular"),
                              ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                navigateToEditPage(peak);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}

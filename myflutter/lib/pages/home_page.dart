import 'package:flutter/material.dart';
import 'dart:async';
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
  Timer? _debounce;

  List<Peak> peaks = [];
  List<Peak> popularPeaks = [];
  List<Peak> filteredPeaks = [];
  List<Peak> filteredPopularPeaks = [];
  final dbOperations = DbOperations.fromSettings();
  bool isLoading = true;
  String? _sortValue;
  bool showPopular = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadPeaks() async {
    try {
      List<Map<String, dynamic>> data =
          await dbOperations.readCollectionWithKeys();
      List<Peak> loadedPeaks = data.map((map) => Peak.fromMap(map)).toList();
      setState(() {
        peaks = loadedPeaks;
        filteredPeaks = loadedPeaks;
        sortPeaks();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load peaks: $e')));
    }
  }

  Future<void> loadPopularPeaks() async {
    try {
      List<Map<String, dynamic>> data = await dbOperations.loadByPopularTag();
      List<Peak> loadedPeaks = data.map((map) => Peak.fromMap(map)).toList();
      setState(() {
        popularPeaks = loadedPeaks;
        filteredPopularPeaks = loadedPeaks;
        sortPopularPeaks();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load popular peaks: $e')),
      );
    }
  }

  void _filterPeaks() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.toLowerCase();
      setState(() {
        if (showPopular) {
          filteredPopularPeaks =
              popularPeaks
                  .where((peak) => peak.name.toLowerCase().contains(query))
                  .toList();
          sortPopularPeaks();
        } else {
          filteredPeaks =
              peaks
                  .where((peak) => peak.name.toLowerCase().contains(query))
                  .toList();
          sortPeaks();
        }
      });
    });
  }

  void navigateToViewPage(Peak peak) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DetailPage(
              peakId: peak.key!, // Передаємо peakId
              onLoginNeeded: widget.onLoginNeeded,
            ),
      ),
    );
    if (result is bool && result == true) {
      await loadPeaks();
      await loadPopularPeaks();
    }
  }

  void toggleView() {
    setState(() {
      showPopular = !showPopular;
    });
  }

  void sortPeaks() {
    if (!showPopular) {
      switch (_sortValue) {
        case 'a-z':
          filteredPeaks.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'z-a':
          filteredPeaks.sort((a, b) => b.name.compareTo(a.name));
          break;
        case '0-1':
          filteredPeaks.sort((a, b) => a.elevation.compareTo(b.elevation));
          break;
        case '1-0':
          filteredPeaks.sort((a, b) => b.elevation.compareTo(a.elevation));
          break;
        default:
          filteredPeaks.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
      }
    }
  }

  void sortPopularPeaks() {
    if (showPopular) {
      switch (_sortValue) {
        case 'a-z':
          filteredPopularPeaks.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'z-a':
          filteredPopularPeaks.sort((a, b) => b.name.compareTo(a.name));
          break;
        case '0-1':
          filteredPopularPeaks.sort(
            (a, b) => a.elevation.compareTo(b.elevation),
          );
          break;
        case '1-0':
          filteredPopularPeaks.sort(
            (a, b) => b.elevation.compareTo(a.elevation),
          );
          break;
        default:
          filteredPopularPeaks.sort(
            (a, b) => b.timestamp!.compareTo(a.timestamp!),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Після зміни стану авторизації перезавантажуємо списки
        if (snapshot.connectionState == ConnectionState.active) {
          if (isLoading) {
            Future.wait([loadPeaks(), loadPopularPeaks()]).then((_) {
              setState(() {
                isLoading = false;
                showPopular = false;
                filteredPeaks = peaks;
                filteredPopularPeaks = popularPeaks;
              });
            });
          }
        }

        final isLoggedIn = snapshot.data != null;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Peaks'),
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
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search peaks...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterPeaks();
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  autofocus: false, // Змінимо пізніше
                  onChanged: (value) => _filterPeaks(),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                      isLoading
                          ? const CircularProgressIndicator()
                          : (showPopular
                              ? filteredPopularPeaks.isEmpty
                              : filteredPeaks.isEmpty)
                          ? const Text(
                            'No peaks found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          )
                          : GridView.builder(
                            padding: const EdgeInsets.all(8.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                ),
                            itemCount:
                                showPopular
                                    ? filteredPopularPeaks.length
                                    : filteredPeaks.length,
                            itemBuilder: (context, index) {
                              final Peak peak =
                                  showPopular
                                      ? filteredPopularPeaks[index]
                                      : filteredPeaks[index];
                              return Card(
                                child: InkWell(
                                  onTap: () => navigateToViewPage(peak),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child:
                                                  peak.imagePath != null &&
                                                          peak
                                                              .imagePath!
                                                              .isNotEmpty
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
                                                    stream: dbOperations
                                                        .isFavourite(peak.key!),
                                                    initialData: false,
                                                    builder: (
                                                      context,
                                                      snapshot,
                                                    ) {
                                                      final isFavourite =
                                                          snapshot.data ??
                                                          false;
                                                      return IconButton(
                                                        icon: Icon(
                                                          isFavourite
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                          color:
                                                              isFavourite
                                                                  ? Colors
                                                                      .red[400]
                                                                  : Colors.grey,
                                                          size: 20,
                                                        ),
                                                        onPressed: () {
                                                          if (!isLoggedIn) {
                                                            Navigator.pushNamed(
                                                              context,
                                                              '/user_page',
                                                            );
                                                            return;
                                                          }
                                                          dbOperations
                                                              .toggleFavourite(
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
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
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
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: toggleView,
            label: Text(showPopular ? 'View All Peaks' : 'View Popular Peaks'),
            icon: Icon(showPopular ? Icons.list : Icons.star),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: 0, // Або динамічно
            onTap: (index) {
              if (index == 1) {
                Navigator.pushNamed(context, '/user_page');
              }
            },
          ),
        );
      },
    );
  }
}

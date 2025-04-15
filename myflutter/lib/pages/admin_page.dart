import 'package:flutter/material.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/api/db_op.dart';
import 'package:myflutter/services/auth_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Peak> peaks = [];
  final dbOperations = DbOperations.fromSettings();
  late bool isLoading;
  String _searchQuery = '';
  String _sortColumn = ''; // Track the sorted column
  bool _sortAscending = true; // Track the sorting direction
  final AuthService _authService = AuthService(); // Додаємо AuthService
  bool _isAccessChecked = false; // Для перевірки доступу
  bool _hasAccess = false; // Чи є доступ до адмін-панелі

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _checkAdminAccess(); // Перевіряємо доступ
  }

  Future<void> _checkAdminAccess() async {
    final user = _authService.currentUser;
    if (user == null) {
      setState(() {
        _isAccessChecked = true;
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to access the admin panel'),
          ),
        );
      });
      return;
    }

    final isAdmin = await _authService.isAdmin(user.uid);
    setState(() {
      _hasAccess = isAdmin;
      _isAccessChecked = true;
      isLoading = false;
    });

    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You do not have admin access')),
        );
      });
    } else {
      loadPeaks(); // Завантажуємо вершини тільки для адмінів
    }
  }

  Future<List<Peak>> loadPeaks() async {
    List<Map<String, dynamic>> data =
        await dbOperations.readCollectionWithKeys();
    List<Peak> loadedPeaks = data.map((map) => Peak.fromMap(map)).toList();
    setState(() {
      isLoading = false;
      peaks = loadedPeaks;
    });
    return loadedPeaks;
  }

  void removePeak(Peak peak) async {
    await dbOperations.removeElement(peak.key!);
    setState(() {
      peaks.remove(peak);
    });
  }

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

  @override
  Widget build(BuildContext context) {
    if (!_isAccessChecked || isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_hasAccess) {
      return const Scaffold(
        body: Center(child: Text('Access Denied')),
      ); // Не має спрацьовувати, бо перенаправлення вже відбулося
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Peaks Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  // Make search field smaller
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ), // Smaller padding
                      border: OutlineInputBorder(), // Add border
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ), // Add spacing between search and button
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    navigateToAddPage();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHeaderRow(),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: peaks.length,
                        itemBuilder: (context, index) {
                          Peak peak = peaks[index];
                          return _buildDataRow(peak);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        _buildHeaderCell('Name', () => _sortPeaks('name')),
        _buildHeaderCell('Elevation', () => _sortPeaks('elevation')),
        _buildHeaderCell('Location', null), // No sorting for location
        const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _buildHeaderCell(String label, VoidCallback? onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Text(label),
            if (onPressed != null)
              IconButton(
                icon: Icon(
                  _sortColumn == label.toLowerCase() && _sortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                ),
                onPressed: () {
                  if (_sortColumn == label.toLowerCase()) {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortColumn = label.toLowerCase();
                    _sortAscending = true;
                  }
                  onPressed();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(Peak peak) {
    return Row(
      children: [
        _buildDataCell(peak.name),
        _buildDataCell(peak.elevation.toString()),
        _buildDataCell(peak.location),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => navigateToEditPage(peak),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.red,
          onPressed: () => removePeak(peak),
        ),
      ],
    );
  }

  Widget _buildDataCell(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(text),
      ),
    );
  }

  void _sortPeaks(String sortBy) {
    setState(() {
      peaks.sort((a, b) {
        if (sortBy == 'name') {
          return _sortAscending
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name);
        } else if (sortBy == 'elevation') {
          return _sortAscending
              ? a.elevation.compareTo(b.elevation)
              : b.elevation.compareTo(a.elevation);
        }
        return 0;
      });
    });
  }
}

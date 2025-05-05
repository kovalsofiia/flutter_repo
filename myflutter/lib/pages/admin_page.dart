import 'package:flutter/material.dart';
import 'package:myflutter/models/peak.dart';
import 'package:myflutter/api/db_op.dart';
import 'package:myflutter/services/auth_service.dart';
import 'dart:async';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Peak> peaks = [];
  List<Peak> filteredPeaks = []; // Додаємо список для відфільтрованих вершин
  final dbOperations = DbOperations.fromSettings();
  late bool isLoading;
  final TextEditingController _searchController =
      TextEditingController(); // Контролер для пошуку
  String _sortColumn = ''; // Track the sorted column
  bool _sortAscending = true; // Track the sorting direction
  final AuthService _authService = AuthService();
  bool _isAccessChecked = false;
  bool _hasAccess = false;
  Timer? _debounce; // Для дебаунсингу

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _checkAdminAccess();
    // Додаємо слухача для текстового поля
    _searchController.addListener(_filterPeaks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
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
            content: Text('Увійдіть, щоб отримати доступ до адмін панелі'),
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
          const SnackBar(content: Text('У вас немає доступу до адмін панелі')),
        );
      });
    } else {
      loadPeaks();
    }
  }

  Future<List<Peak>> loadPeaks() async {
    List<Map<String, dynamic>> data =
        await dbOperations.readCollectionWithKeys();
    List<Peak> loadedPeaks = data.map((map) => Peak.fromMap(map)).toList();
    setState(() {
      isLoading = false;
      peaks = loadedPeaks;
      filteredPeaks = loadedPeaks; // Ініціалізуємо відфільтрований список
    });
    return loadedPeaks;
  }

  void removePeak(Peak peak) async {
    await dbOperations.removeElement(peak.key!);
    setState(() {
      peaks.remove(peak);
      filteredPeaks.remove(peak); // Оновлюємо відфільтрований список
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

  // Метод для фільтрації вершин
  void _filterPeaks() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredPeaks =
            peaks.where((peak) {
              // Перевіряємо всі поля, враховуючи можливі null значення
              final nameMatch = peak.name.toLowerCase().contains(query);
              final elevationMatch = peak.elevation.toString().contains(query);
              final locationMatch = peak.location.toLowerCase().contains(query);
              final descriptionMatch = peak.description.toLowerCase().contains(
                query,
              );

              // Вершина відповідає, якщо хоча б одне поле містить запит
              return nameMatch ||
                  elevationMatch ||
                  locationMatch ||
                  descriptionMatch;
            }).toList();
        _sortPeaks(_sortColumn); // Повторно застосовуємо сортування
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAccessChecked || isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_hasAccess) {
      return const Scaffold(body: Center(child: Text('У доступі відмовлено')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Вершини Адмін Сторінка')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController, // Використовуємо контролер
                    decoration: const InputDecoration(
                      labelText: 'Пошук',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                        itemCount:
                            filteredPeaks
                                .length, // Використовуємо filteredPeaks
                        itemBuilder: (context, index) {
                          Peak peak = filteredPeaks[index];
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
        _buildHeaderCell('Назва', () => _sortPeaks('name')),
        _buildHeaderCell('Висота', () => _sortPeaks('elevation')),
        _buildHeaderCell('Локація', null),
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
      filteredPeaks.sort((a, b) {
        // Сортуємо filteredPeaks
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
      _sortColumn = sortBy; // Оновлюємо поточну колонку сортування
    });
  }
}

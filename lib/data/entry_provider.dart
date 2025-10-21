import 'package:flutter/material.dart';
import 'entry.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EntryProvider extends ChangeNotifier {
  bool useCloud = false; // Toggle between local and cloud save
  bool listEnabled = true; // Toggles numbered list feature

  late Box<Entry> _localBox;
  final _firestore = FirebaseFirestore.instance.collection('entries');

  List<Entry> _entries = [];
  List<Entry> get entries => _entries;

  // -------------------- MOCK TIME SYSTEM --------------------

  DateTime? mockNow;

  /// Returns the active time source (mock or real)
  DateTime get currentTime => mockNow ?? DateTime.now();

  /// Set a mock date for debugging
  void setMockDate(DateTime date) {
    mockNow = date;
    debugPrint('🕒 Mock time activated: ${mockNow!.toIso8601String()}');
    notifyListeners();
  }

  /// Clear mock date and return to system time
  void clearMockDate() {
    debugPrint('⏱️ Mock time cleared — using real system clock.');
    mockNow = null;
    notifyListeners();
  }

  EntryProvider() {
    _loadNumberedList();
  }

  // -------------------- INITIALIZATION --------------------

  Future<void> init() async {
    _localBox = Hive.box<Entry>('entries');
    await loadEntries();
  }

  // -------------------- CLOUD / LOCAL TOGGLE --------------------

  Future<void> toggelStorage(bool value) async {
    if (value && !useCloud) {
      await _mergeLocalToCloud();
    } else if (!value && useCloud) {
      await _mergeCloudToLocal();
    }
    useCloud = value;
    await loadEntries();
    notifyListeners();
  }

  // -------------------- LOAD ENTRIES --------------------

  Future<void> loadEntries() async {
    if (useCloud) {
      final snapshot = await _firestore.get();
      _entries = snapshot.docs.map((doc) {
        final data = doc.data();
        return Entry(
          title: data['title'] ?? '',
          date: data['date'] is Timestamp
              ? (data['date'] as Timestamp).toDate()
              : DateTime.parse(data['date'].toString()),
          priority: data['priority'] ?? 1,
          category: data['category'] ?? 'Other',
          imagePath: data['image'],
        );
      }).toList();
    } else {
      _entries = _localBox.values.toList();
    }
    notifyListeners();
  }

  // -------------------- CRUD OPERATIONS --------------------

  Future<void> addEntry(Entry entry) async {
    if (useCloud) {
      await _firestore.add({
        'title': entry.title,
        'priority': entry.priority,
        'date': entry.date.toIso8601String(),
        'category': entry.category,
        'image': entry.imagePath
      });
    } else {
      await _localBox.add(entry);
    }
    await loadEntries();
  }

  Future<void> deleteEntry(int index) async {
    if (useCloud) {
      final docId = (await _firestore.get()).docs[index].id;
      await _firestore.doc(docId).delete();
    } else {
      await _localBox.deleteAt(index);
    }
    await loadEntries();
  }

  Future<void> saveEntry(Entry entry) async {
    if (useCloud) {
      final snapshot = await _firestore
          .where('title', isEqualTo: entry.title)
          .where('date', isEqualTo: entry.date.toIso8601String())
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        await _firestore.doc(docId).update({
          'title': entry.title,
          'priority': entry.priority,
          'date': entry.date.toIso8601String(),
          'category': entry.category,
          'image': entry.imagePath,
        });
      }
    } else {
      await entry.save();
    }
    await loadEntries();
    notifyListeners();
  }

  Future<void> updateEntry(Entry entry) async => saveEntry(entry);

  void clearAllEntries() async {
    await _localBox.clear();
    _entries.clear();
    notifyListeners();
  }

  // -------------------- DATA SYNC HELPERS --------------------

  Future<void> _mergeLocalToCloud() async {
    final localEntries = _localBox.values.toList();
    final cloudSnapshot = await _firestore.get();

    final cloudEntries = cloudSnapshot.docs.map((doc) {
      final data = doc.data();
      return Entry(
        title: data['title'],
        date: data['date'] is Timestamp
            ? (data['date'] as Timestamp).toDate()
            : DateTime.parse(data['date'].toString()),
        priority: data['priority'],
        imagePath: data['image'],
      );
    }).toList();

    for (var entry in localEntries) {
      if (!_containsEntry(cloudEntries, entry)) {
        await _firestore.add({
          'title': entry.title,
          'priority': entry.priority,
          'date': entry.date,
          'category': entry.category,
          'image': entry.imagePath
        });
      }
    }
  }

  Future<void> _mergeCloudToLocal() async {
    final cloudSnapshot = await _firestore.get();
    final cloudEntries = cloudSnapshot.docs.map((doc) {
      final data = doc.data();
      return Entry(
        title: data['title'],
        date: data['date'] is Timestamp
            ? (data['date'] as Timestamp).toDate()
            : DateTime.parse(data['date'].toString()),
        priority: data['priority'],
        category: data['category'],
        imagePath: data['image'],
      );
    }).toList();

    final localEntries = _localBox.values.toList();

    for (var entry in cloudEntries) {
      if (!_containsEntry(localEntries, entry)) {
        await _localBox.add(entry);
      }
    }
  }

  Future<void> mergeCloudToLocal(bool deleteCloud) async {
    await _mergeCloudToLocal();
    if (deleteCloud) {
      final cloudSnapshot = await _firestore.get();
      for (var doc in cloudSnapshot.docs) {
        await _firestore.doc(doc.id).delete();
      }
    }
    useCloud = false;
    await loadEntries();
    notifyListeners();
  }

  // -------------------- STREAK SYSTEM --------------------

  int get streakCount {
    if (entries.isEmpty) return 0;

    final today = currentTime;
    final todayDate = _onlyDate(today);

    final uniqueDates = entries
        .map((e) => _onlyDate(e.date))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (uniqueDates.first != todayDate) return 0;

    int streak = 1;
    DateTime current = uniqueDates.first;

    for (int i = 1; i < uniqueDates.length; i++) {
      final difference = current.difference(uniqueDates[i]).inDays;
      if (difference == 1) {
        streak++;
        current = uniqueDates[i];
      } else {
        break;
      }
    }

    return streak;
  }

  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  List<DateTime> get last7Days {
    final now = currentTime;
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _onlyDate(day);
    });
  }

  bool hasEntryOn(DateTime day) {
    final normalized = _onlyDate(day);
    return entries.any((e) => _onlyDate(e.date) == normalized);
  }

  Map<DateTime, bool> get entriesByDay {
    final map = <DateTime, bool>{};
    for (final day in last7Days) {
      map[day] = hasEntryOn(day);
    }
    return map;
  }

  // -------------------- HELPER FUNCTIONS --------------------

  bool _containsEntry(List<Entry> list, Entry entry) {
    return list.any((e) =>
        e.title == entry.title &&
        e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day);
  }

  // -------------------- NUMBERED LIST --------------------

  List<String> numberedItems = [];

  Future<void> _loadNumberedList() async {
    final settingsBox = Hive.box('settings');
    final listBox = Hive.box('numberedList');

    listEnabled = settingsBox.get('listEnabled', defaultValue: true);
    numberedItems =
        (listBox.get('items', defaultValue: <String>[]) as List).cast<String>();
    notifyListeners();
  }

  void toggleListEnabel(bool value) {
    listEnabled = value;
    Hive.box('settings').put('listEnabled', value);
    notifyListeners();
  }

  void updateItem(int index, String value) {
    if (index >= 0 && index < numberedItems.length) {
      numberedItems[index] = value;
      Hive.box('numberedList').put('items', numberedItems);
      notifyListeners();
    }
  }

  void addItem() {
    numberedItems.add('');
    Hive.box('numberedList').put('items', numberedItems);
    notifyListeners();
  }

  void removeItem(int index) {
    numberedItems.removeAt(index);
    Hive.box('numberedList').put('items', numberedItems);
    notifyListeners();
  }

  void reorderItems(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = numberedItems.removeAt(oldIndex);
    numberedItems.insert(newIndex, item);
    Hive.box('numberedList').put('items', numberedItems);
    notifyListeners();
  }

  void saveNumberedItems() {
    Hive.box('numberedList').put('items', numberedItems);
    notifyListeners();
  }
}

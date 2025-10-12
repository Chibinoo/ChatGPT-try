import 'package:hive/hive.dart';

part 'entry.g.dart';

@HiveType(typeId: 0)
class Entry {
  @HiveField(0)
  late String title;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  late int priority;

  @HiveField(3)
  late String category;

  @HiveField(4)
  String? imagePath;

  Entry({
    required this.title,
    required this.date,
    required this.priority,
    this.category = 'Other',
    this.imagePath,
  });

  /// ✅ Convert to Firestore-safe map
  Map<String, dynamic> toMap() {
    return {
      'title': title, // ✅ fixed key
      'priority': priority,
      'date': date.toIso8601String(),
      'category': category,
      'image': imagePath, // ✅ match provider field name
    };
  }

  /// ✅ Factory for Firestore or Hive-safe map parsing
  factory Entry.fromMap(Map<String, dynamic> map) {
  final titleValue = map['title'] ?? map['titel'] ?? 'Untitled';

  return Entry(
    title: titleValue as String,
    date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    priority: map['priority'] ?? 1,
    category: map['category'] ?? 'Other',
    imagePath: map['imagePath'],
  );
}

  /// Hive auto-generated methods need a save() placeholder if using HiveObject
  Future<void> save() async {}
}

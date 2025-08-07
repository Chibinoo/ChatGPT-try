import 'package:hive/hive.dart';

part 'entry.g.dart';

@HiveType(typeId: 0)
class Entry {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int priority;
  
  @HiveField(3)
  final String category;

  Entry({
    required this.title, 
    required this.date, 
    required this.priority,
    this.category='Other'
  });
}
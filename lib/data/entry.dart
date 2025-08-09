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

  @HiveField(4)
  String? imagePath;

  Entry({
    required this.title, 
    required this.date, 
    required this.priority,
    this.category='Other',
    this.imagePath
  });

  //Convert for firestore
  Map<String, dynamic>toMap(){
    return{
      'titel':title,
      'priority':priority,
      'date':date.toIso8601String(),
      'category':category,
      'imagePath':imagePath
    };
  }
  factory Entry.fromMap(Map<String, dynamic>map){
    return Entry(
      title: map['titel'], 
      date: DateTime.parse(map['date']),
      priority: map['priority'],
      category: map['category']??'Other',
      imagePath: map['imagePath'],
    );
  }
}
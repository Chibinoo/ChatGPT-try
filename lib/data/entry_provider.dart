import 'package:flutter/material.dart';
import 'entry.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EntryProvider extends ChangeNotifier {
  bool useCloud=false;//toggel betwin local and cloud save
  bool listEnabled=true;//toggels notfallplan on and off

  void setUseCloud(bool value){
    useCloud=value;
    notifyListeners();
  }

  late Box<Entry>_localBox;
  final _firestore=FirebaseFirestore.instance.collection('entries');

  List<Entry> _entries = [];
  List<Entry> get entries => _entries;

  Future<void> init() async {
    _localBox=Hive.box<Entry>('entries');
    await loadEntries();
  }
//toggel storage and sync data
  Future<void> toggelStorage(bool value) async{
    if(value && !useCloud){
      await _mergeLocalToCloud();
    } else if(!value && useCloud){
      await _mergeCloudToLocal();
    }
    useCloud=value;
    await loadEntries();
    notifyListeners();
  }
//load entries
  Future<void> loadEntries() async{
    if(useCloud){
      //use Firestore
      final snapshot=await _firestore.get();
      _entries=snapshot.docs.map((doc){
        final data=doc.data();
        return Entry(
          title: data['title'], 
          date: data['date'] is Timestamp
            ? (data['date'] as Timestamp).toDate()
            : DateTime.parse(data['date'].toString()),
          priority: data['priority'],
          category: data['category']??'Other',
          imagePath: data['image']
        );
      }).toList();
    } else{
      //use Hive
      _entries=_localBox.values.toList();
    }
    notifyListeners();
  }
//add entry
  Future<void> addEntry(Entry entry) async{
    if(useCloud){
      await _firestore.add({
        'title':entry.title,
        'priority':entry.priority,
        'date':entry.date.toIso8601String(),
        'category':entry.category,
        'image':entry.imagePath
      });
    } else{
      await _localBox.add(entry);
    }
    await loadEntries();
  }
//delete entry
  Future<void> deleteEntry(int index) async{
    if(useCloud){
      final docId=(await _firestore.get()).docs[index].id;
      await _firestore.doc(docId).delete();
    } else{
      await _localBox.deleteAt(index);
    }
    await loadEntries();
  }
//merge local to cloud
Future<void> _mergeLocalToCloud()async{
  final localEntries=_localBox.values.toList();
  final cloudSnapshot=await _firestore.get();
  final cloudEntries=cloudSnapshot.docs.map((doc){
    final data=doc.data();
    return Entry(
      title: data['title'], 
      date: data['date'] is Timestamp
        ? (data['date'] as Timestamp).toDate()
        : DateTime.parse(data['date'].toString()), 
      priority: data['priority'],
      imagePath: data['image']
    );
  }).toList();
  //for each local entry missing in cloud, upload it
  for(var entry in localEntries){
    if(!_containsEntry(cloudEntries, entry)){
      await _firestore.add({
        'title':entry.title,
        'priority':entry.priority,
        'date':entry.date,
        'category':entry.category,
        'image':entry.imagePath
      });
    }
  }
}
//merge cloud to local
Future<void> _mergeCloudToLocal()async{
  final cloudSnapshot=await _firestore.get();
  final cloudEntries=cloudSnapshot.docs.map((doc){
    final data=doc.data();
    return Entry(
      title: data['title'], 
      date: data['date'] is Timestamp
        ? (data['date'] as Timestamp).toDate()
        : DateTime.parse(data['date'].toString()), 
      priority: data['priority'],
      category: data['category'],
      imagePath: data['image']
    );
  }).toList();
  final localEntries=_localBox.values.toList();
  //for each cloud entry missing in local, add it
  for(var entry in cloudEntries){
    if(!_containsEntry(localEntries, entry)){
      await _localBox.add(entry);
    }
  }
}
Future<void> mergeCloudToLocal(bool deleteCloud) async{
  //merge cloud data first
  await _mergeCloudToLocal();

  //if user accepted deletion, clear cloud data
  if(deleteCloud){
    final cloudSnapshot=await _firestore.get();
    for(var doc in cloudSnapshot.docs){
      await _firestore.doc(doc.id).delete();
    }
  }
  //switch to local storage
  useCloud=false;
  await loadEntries();
  notifyListeners();
}

Future<List<Entry>> getAllEntries() async {
  List<Entry> entriesList=[];
  if (useCloud) {
    final snapshot = await FirebaseFirestore.instance.collection('entries').get();
    for(var doc in snapshot.docs){
      final data=doc.data();
      final date=parseDate(data['data']);

      entriesList.add(Entry(
        title: data['title']??'', 
        priority: data['priority']??1,
        date: date, 
        category: data['category']??'Other',
        imagePath: data['image'],
        ));
    }
  }else{
    final box=Hive.box<Entry>('entries');
    for(var entry in box.values){
      entriesList.add(Entry(
        title: entry.title,
        priority: entry.priority, 
        date: entry.date, 
        category:entry.category,
        imagePath:entry.imagePath,
        ));
    }
  }
  return entriesList;
}
//helper for date 
DateTime parseDate(dynamic value){
  if(value is String){
    return DateTime.parse(value);
  }else if(value is Timestamp){
    return value.toDate();
  }else if(value is DateTime){
    return value;
  }else{
    throw Exception('Unsupported date type:${value.runtimeType}');
  }
}

///Helper: check if entry exists(based on titel+date)
bool _containsEntry(List<Entry> list, Entry entry){
  return list.any((e)=>
    e.title==entry.title&&
    e.date.year==entry.date.year&&
    e.date.month==entry.date.month&&
    e.date.day==entry.date.day);
}
bool isCloudMode=false;
void switchMode(bool cloud){
  isCloudMode=cloud;
  notifyListeners();
}

//steak system
int get streakCount {
  if (entries.isEmpty) return 0;
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  final uniqueDates = entries
      .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a)); // newest first

  int streak = 1;
  DateTime currentDay = uniqueDates.first;

  for (int i = 1; i < uniqueDates.length; i++) {
    final difference = currentDay.difference(uniqueDates[i]).inDays;
    if (difference == 1) {
      streak++;
      currentDay = uniqueDates[i];
    } else {
      break; // streak broken
    }
  }
  // if no entry today, streak is 0
  if (uniqueDates.first != todayDate) {
    streak = 0;
  }
  return streak;
}

  get sortedEntries {
  // ignore: unnecessary_null_comparison
  if (_entries == null) return [];
  final list = List<Entry>.from(_entries);
  list.sort((a, b) => b.priority.compareTo(a.priority));
  return list;
}

/// Save changes to an existing entry (local or cloud)
Future<void> saveEntry(Entry entry) async {
  if (useCloud) {
    // Find the document in Firestore by matching title and date
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
    // For Hive, just call save() on the entry (if it's a HiveObject)
    await entry.save();
  }
  await loadEntries();
  notifyListeners();
}

/// Update an existing entry (local or cloud)
Future<void> updateEntry(Entry entry) async {
  if (useCloud) {
    // Find the document in Firestore by matching title and date
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
    // For Hive, just call save() on the entry (if it's a HiveObject)
    await entry.save();
  }
  await loadEntries();
  notifyListeners();
}

//clear all entries
void clearAllEntries()async{
  await _localBox.clear();//clears hive box
  entries.clear();//clear local list
  notifyListeners();
}

//helper for streak tiles
List<DateTime> get last7Days{
  final now=DateTime.now();
  return List.generate(7, (i){
    final day=now.subtract(Duration(days: 6-i));
    return DateTime(day.year, day.month, day.day);
  });
}
bool hasEntryOn(DateTime day){
  return entries.any((e){
    final d=DateTime(e.date.year, e.date.month, e.date.day);
    return d==day;
  });
}

//notfallplan
List<String>numberedItems=[];

EntryProvider(){
  _loadNumberedList();
}

Future<void> _loadNumberedList()async{
  final settingsBox=Hive.box('settings');
  final listBox=Hive.box('numberedList');

  listEnabled=settingsBox.get('listEnabeled', defaultValue: true);
  numberedItems=(listBox.get('items',defaultValue: <String>[])as List).cast<String>();
  notifyListeners();
}
void toggleListEnabel(bool value){
  listEnabled=value;
  Hive.box('settings').put('listEnabled', value);
  notifyListeners();
}
void updateItem(int index, String value) {
  if (index >= 0 && index < numberedItems.length) {
    numberedItems[index] = value;
    Hive.box('numberedList').put('items', numberedItems); // <-- Save after every change
    notifyListeners();
  }
}
void addItem(){
  numberedItems.add('');
  Hive.box('numberedList').put('items', numberedItems);
  notifyListeners();
}
void removeItem(int index){
  numberedItems.removeAt(index);
  Hive.box('numberedList').put('items', numberedItems);
  notifyListeners();
}
void reorderItems(int oldIndex, int newIndex) {
  if (oldIndex < newIndex) {
    newIndex -= 1;
  }
  final item = numberedItems.removeAt(oldIndex);
  numberedItems.insert(newIndex, item);
  Hive.box('numberedList').put('items', numberedItems); // Persist changes
  notifyListeners();
}
void saveNumberedItems(){
  Hive.box('numberedList').put('item', numberedItems);
  notifyListeners();
}
}
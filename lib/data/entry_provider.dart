import 'package:flutter/material.dart';
import 'entry.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EntryProvider with ChangeNotifier {
  bool useCloud=false;//toggel betwin local and cloud save
  late Box<Entry>_localBox;
  final _firestore=FirebaseFirestore.instance.collection('entries');

  List<Entry> _entries = [];
  List<Entry> get entries => _entries;

  Future<void> init()async{
    _localBox=await Hive.openBox<Entry>('entries');
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
int get streakCount{
  if(entries.isEmpty) return 0;
  //get unique dates
  final uniqueDates=entries.map((e)=>DateTime(e.date.year, e.date.month, e.date.day)).toSet().toList()
  ..sort((a,b)=>b.compareTo(a));//newest first
  int streak=1;
  DateTime currentDay=uniqueDates.first;

  for(int i=1;i<uniqueDates.length;i++){
    final difference=currentDay.difference(uniqueDates[i]).inDays;
    if(difference==1){
      streak++;
      currentDay=uniqueDates[i];
    }else{
      break;//streak broken
    }
  }
  //if no entry today, streak is 0
  if(uniqueDates.first!=DateTime.now().toLocal().subtract(const Duration(days: 0))&&
  uniqueDates.first!=DateTime.now()){
    streak=0;
  }
  return streak;
}
}
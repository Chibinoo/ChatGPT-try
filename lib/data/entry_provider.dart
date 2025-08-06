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

  void toggelStorage(bool value) async{
    useCloud=value;
    await loadEntries();
    notifyListeners();
  }

  Future<void> loadEntries() async{
    if(useCloud){
      //use Firestore
      final snapshot=await _firestore.get();
      _entries=snapshot.docs.map((doc){
        final data=doc.data();
        return Entry(
          title: data['title'], 
          date: DateTime.parse(data['date']), 
          priority: data['priority']
        );
      }).toList();
    } else{
      //use Hive
      _entries=_localBox.values.toList();
    }
    notifyListeners();
  }

  Future<void> addEntry(Entry entry) async{
    if(useCloud){
      await _firestore.add({
        'title':entry.title,
        'priority':entry.priority,
        'date':entry.date.toIso8601String(),
      });
    } else{
      await _localBox.add(entry);
    }
    await loadEntries();
  }
  Future<void> deleteEntry(int index) async{
    if(useCloud){
      final docId=(await _firestore.get()).docs[index].id;
      await _firestore.doc(docId).delete();
    } else{
      await _localBox.deleteAt(index);
    }
    await loadEntries();
  }
}
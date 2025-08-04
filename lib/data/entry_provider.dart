import 'package:flutter/material.dart';
import 'entry.dart';
import 'package:hive/hive.dart';

class EntryProvider with ChangeNotifier {
  final Box<Entry> _box=Hive.box<Entry>('entries');

  List<Entry> get entries => _box.values.toList();

  void addEntry(Entry entry){
    _box.add(entry);
    notifyListeners();
  }

  void clearEntries(){
    _box.clear();
    notifyListeners();
  }

  void deleteEntry(int index){
    _box.deleteAt(index);
    notifyListeners();
  }
}
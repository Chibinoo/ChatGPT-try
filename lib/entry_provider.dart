import 'package:flutter/material.dart';
import 'entry.dart';

class EntryProvider with ChangeNotifier {
  final List<Entry> _entries=[];

  List<Entry> get entries => _entries;

  void addEntry(Entry entry){
    _entries.add(entry);
    notifyListeners();
  }

  void clearEntries(){
    _entries.clear();
    notifyListeners();
  }
}
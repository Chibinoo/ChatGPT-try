import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry.dart';
import 'package:flutter_application_1/widgets/widget_tree.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'data/entry_provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //init cloud save
  await Firebase.initializeApp();
//init local save
  await Hive.initFlutter();
  Hive.registerAdapter(EntryAdapter());
  await Hive.openBox<Entry>('entries');

  final entryProvider=EntryProvider();
  await entryProvider.init();

  runApp(
    ChangeNotifierProvider.value(
      value: entryProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Entries App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WidgetTree(),
    );
  }
}

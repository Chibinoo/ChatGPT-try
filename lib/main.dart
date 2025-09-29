import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry.dart';
import 'package:flutter_application_1/pages/add_entry_page.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
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

  await Hive.openBox('settings');
  await Hive.openBox('numberedList');

  final entryProvider=EntryProvider();
  await entryProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: entryProvider,
        ),
        ChangeNotifierProvider.value(value: ThemeProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Entries App',
      theme: themeProvider.themeData, // <-- use your provider's theme
      initialRoute: '/add',
      routes: {
        '/add':(context)=>const AddEntryPage(),
        '/main':(context)=>const WidgetTree(),
      },
    );
  },
    );
}
}
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:flutter_application_1/data/notifiers.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:flutter_application_1/pages/sorted_page.dart';
import 'package:flutter_application_1/pages/stats_page.dart';
import 'package:flutter_application_1/widgets/navbar_widget.dart';
import 'package:provider/provider.dart';

List<Widget> pages=[
  SortedPage(),
  StatsPage(),
  SettingsPage()
];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  void initState() {
  super.initState();
    Provider.of<EntryProvider>(context, listen: false).listenToAuthChanges(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier, 
        builder: (context, selectedPage, child){
          return pages.elementAt(selectedPage);
        }
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
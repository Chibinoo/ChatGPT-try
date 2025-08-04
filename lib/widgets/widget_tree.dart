import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/notifiers.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/sorted_page.dart';
import 'package:flutter_application_1/pages/stats_page.dart';
import 'package:flutter_application_1/widgets/navbar_widget.dart';

List<Widget> pages=[
  HomePage(),
  SortedPage(),
  StatsPage()
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

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
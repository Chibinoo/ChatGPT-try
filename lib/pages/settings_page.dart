import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Local Storage'),
            Switch(
              value: entryProvider.useCloud, 
              onChanged: (value) => entryProvider.toggelStorage(value),
            ),
            const Text('Cloud Storage'),
          ],
        ),
      ),
    );
  }
}
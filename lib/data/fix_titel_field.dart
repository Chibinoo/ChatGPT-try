// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> migrateTitelToTitle() async {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('entries');

  print('🔍 Starting migration of Firestore entries...');
  final snapshot = await collection.get();
  int updated = 0;
  int skipped = 0;

  for (final doc in snapshot.docs) {
    final data = doc.data();
    if (data.containsKey('titel')) {
      final oldValue = data['titel'];
      await collection.doc(doc.id).update({
        'title': oldValue ?? 'Untitled',
        'titel': FieldValue.delete(),
      });
      updated++;
      print('✅ Updated doc ${doc.id} (titel → title)');
    } else {
      skipped++;
    }
  }

  print('🎉 Migration done. $updated fixed, $skipped skipped.');
}

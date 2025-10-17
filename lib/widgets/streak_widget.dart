import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:provider/provider.dart';

class StreakWidget extends StatelessWidget {
  const StreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final streak = context.watch<EntryProvider>().streakCount;
    final color = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.orange, size: 40),
            const SizedBox(width: 16),
            Text(
              streak > 0 ? '$streak day streak' : 'No streak yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

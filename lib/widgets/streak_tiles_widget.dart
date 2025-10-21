import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StreakTilesWidget extends StatelessWidget {
  const StreakTilesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryProvider>();
    final days = provider.last7Days;
    final entriesByDay = provider.entriesByDay;
    final streakCount = provider.streakCount;

    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...days.map((day) {
            final hasEntry = entriesByDay[day] ?? false;
            final isToday = day == DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            );

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: hasEntry
                          ? colorScheme.secondaryContainer
                          : colorScheme.secondary,
                      border: Border.all(
                        color: isToday ? colorScheme.secondary : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('E').format(day).substring(0, 1),
                        style: TextStyle(
                          color: hasEntry
                              ? Colors.black
                              : colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            );
          }),
          // Streak counter tile
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$streakCount🔥',
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

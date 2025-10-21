import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:flutter_application_1/widgets/calender_streak_widget.dart';
import 'package:flutter_application_1/widgets/streak_widget.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/entry.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = Provider.of<EntryProvider>(context).entries;

    //count priorities
    Map<int, int> priorityCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (Entry entry in entries) {
      priorityCount[entry.priority] = (priorityCount[entry.priority] ?? 0) + 1;
    }
    //count categories
    Map<String, int> categoryCounts = {};
    for (var e in entries) {
      categoryCounts[e.category] = (categoryCounts[e.category] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics', style: TextStyle(fontSize: 25)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreakWidget(),
            const SizedBox(height: 5),
            
            CalenderStreakWidget(),
            const SizedBox(height: 5),

            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Entries per priority',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          barGroups: priorityCount.entries.map((entry) {
                            final priority = entry.key;
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.toDouble(),
                                  color: _getPriorityColor(priority),
                                ),
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) =>
                                    Text(value.toInt().toString()),
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 5),

            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Category Distribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: categoryCounts.isEmpty
                              ? [
                                  PieChartSectionData(
                                    value: 1,
                                    title: 'No Data',
                                    radius: 80,
                                    color: Colors.grey[300]!,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ]
                              : categoryCounts.entries.map((entry) {
                                  final percentage =
                                      (entry.value / entries.length) * 100;
                                  return PieChartSectionData(
                                    value: entry.value.toDouble(),
                                    title:
                                        '${entry.key}\n${percentage.toStringAsFixed(1)}%',
                                    radius: 80,
                                    color: _getCategoryColor(entry.key),
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //helper for priority colors
  static Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
      case 2:
        return Colors.green;
      case 3:
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  //helper for category colors
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.blue;
      case 'Hobby':
        return Colors.green;
      case 'Personal':
        return Colors.orange;
      case 'Other':
      default:
        return Colors.grey;
    }
  }
}

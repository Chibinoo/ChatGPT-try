import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/entry.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries=Provider.of<EntryProvider>(context).entries;

    //count priorities
    Map<int,int> priorityCount={1:0, 2:0, 3:0, 4:0, 5:0};
    for (Entry entry in entries){
      priorityCount[entry.priority]=(priorityCount[entry.priority]??0)+1;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Center(
        child: entries.isEmpty
        ? const Text('No data to display yet')
        :Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Entries per priority',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              const SizedBox(height: 20,),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (priorityCount.values.isEmpty
                    ? 1
                    :priorityCount.values.reduce((a,b)=>a>b?a:b))+1,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,  
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 14),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: priorityCount.entries.map((e) {
                      final priority=e.key;
                      final count=e.value;
                      return BarChartGroupData(
                        x:priority,
                        barRods:[
                          BarChartRodData(
                            toY: count.toDouble(),
                            color: _getPriorityColor(priority),
                            width: 20,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //color based on priority
  static Color _getPriorityColor(int priority){
    switch(priority){
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
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StreakTilesWidget extends StatelessWidget {
  final Map<DateTime, bool> entriesByDay;//date->has entry
  final int streakCount;

  const StreakTilesWidget({
    super.key,
    required this.entriesByDay,
    required this.streakCount
    });

  @override
  Widget build(BuildContext context) {
    final now=DateTime.now();
    final today= DateTime(now.year, now.month, now.day);

    //show last 7 days+ today
    final days=List.generate(7, (i)=>today.subtract(Duration(days: 6-i)));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...days.map((day){
            final hasEntry=entriesByDay[day]??false;
            final isToday=day==DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day
              );

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: hasEntry?Colors.green:Colors.grey[300],
                      border: Border.all(
                        color: isToday?Colors.blue:Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('E').format(day).substring(0,1),
                        style: TextStyle(
                          color: hasEntry?Colors.white:Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4,),
                  Text('${day.day}',style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }),

          //streak counter tile
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$streakCount🔥',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
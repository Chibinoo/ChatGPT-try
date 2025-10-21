import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/entry_provider.dart';
import 'package:provider/provider.dart';

class CalenderStreakWidget extends StatefulWidget {
  const CalenderStreakWidget({super.key});

  @override
  State<CalenderStreakWidget> createState() => _CalenderStreakWidgetState();
}

class _CalenderStreakWidgetState extends State<CalenderStreakWidget> {
  late DateTime _displayedMonth;
  

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<EntryProvider>(context, listen: false);
    _displayedMonth=provider.currentTime;
  }

  void _previousMonth(){
    setState(() {
      _displayedMonth=DateTime(
        _displayedMonth.year,
        _displayedMonth.month-1
      );
    });
  }

  void _nextMonth(){
    setState(() {
      _displayedMonth=DateTime(
        _displayedMonth.year,
        _displayedMonth.month+1
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EntryProvider>(context);
    final theme=Theme.of(context).colorScheme;

    final currentNow=provider.currentTime;
    final firstDayOfMonth=DateTime(_displayedMonth.year, _displayedMonth.month,1);
    final daysInMonth=DateUtils.getDaysInMonth(_displayedMonth.year, _displayedMonth.month);
    final days=List.generate(daysInMonth, (i)=>DateTime(_displayedMonth.year,_displayedMonth.month, i+1));
    final startOffset=(firstDayOfMonth.weekday%7);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //Header with month navigation and current time inticator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth, 
                  icon: const Icon(Icons.arrow_left)
                  ),
                  Column(
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_displayedMonth),
                        style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                      ),
                      if(provider.mockNow!=null)
                        Text(
                          'Mock date: ${DateFormat('MMM d, yyyy - HH:mm').format(provider.currentTime)}',
                          style: TextStyle(fontSize: 12,color: theme.primary),
                        ),
                    ],
                  ),
                  IconButton(
                    onPressed: _nextMonth, 
                    icon: const Icon(Icons.arrow_right),
                    ),
              ],
            ),
            const SizedBox(height: 8),

            //Weekday labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                7, 
                (i)=>Expanded(
                  child: Center(
                    child: Text(
                      DateFormat.E().format(DateTime(2020,1,i+1)),
                      style: TextStyle(
                        color: theme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ),
                ),
            ),
            const SizedBox(height: 8),

            //Calender grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: startOffset+days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                ), 
              itemBuilder: (context, index){
                if(index<startOffset){
                  return const SizedBox.shrink();
                }

                final day=days[index-startOffset];
                final hasEntry=provider.hasEntryOn(day);
                final isToday=DateUtils.isSameDay(day, currentNow);

                return GestureDetector(
                  onTap: () {
                    if(hasEntry){
                      _showEntriesDialog(context,provider,day);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: hasEntry
                      ?theme.secondaryContainer
                      :theme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday?theme.primary:Colors.transparent,
                      width: isToday?2:0,
                    ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: hasEntry
                            ?theme.onPrimary
                            :theme.onSurface,
                          fontWeight: isToday?FontWeight.bold:FontWeight.normal,
                        ),
                      ),
                    ),
                    ),
                );
              },
              ),
          ],
        ),
        ),
    );
  }

//Shows a dialog listing all entries for the selected day
void _showEntriesDialog(BuildContext context, EntryProvider provider, DateTime day){
  final dayEntries=provider.entries.where((e)=>DateUtils.isSameDay(e.date, day)).toList();

  showDialog(
    context: context, 
    builder: (_)=>AlertDialog(
      title: Text('Entries on ${DateFormat('MMM d, yyyy').format(day)}'),
      content: dayEntries.isEmpty
        ?const Text('No entries found.')
        :SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dayEntries.length,
            itemBuilder: (context, index){
              final entry=dayEntries[index];
              return ListTile(
                title: Text(entry.title),
                subtitle: Text('Category: ${entry.category}'),
                trailing: Text('Priority: ${entry.priority}'),
              );
            },
            ),
        ),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(context), 
            child: const Text('Close'),
            )
        ],
    ),
    );
}
}
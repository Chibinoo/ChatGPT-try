import 'package:flutter/material.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import '../data/entry_provider.dart';
import '../data/entry.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    final _titleControler=TextEditingController();
    double _priority=1;//default slider value
    DateTime _selectedDate=DateTime.now();
    String _selectedCategory='Other';

    final List<String> _categories=['Work','Hobby','Personal','Other'];

    //Get slider color based on priority level
    Color _getSliderColor(double value){
      if(value<=2) return Colors.green; //low
      if(value<=4) return Colors.orange; //mid
      return Colors.red;//high
    }
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Entries'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleControler,
              decoration: const InputDecoration(labelText: 'Titel'),
            ),
            const SizedBox(height: 20),
            //priority slider with color
            Text(
              'Priority: ${_priority.toInt()}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getSliderColor(_priority),
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _getSliderColor(_priority),
                thumbColor: _getSliderColor(_priority),
                overlayColor: _getSliderColor(_priority).withOpacity(0.2),
                inactiveTrackColor: Colors.grey[300]
              ), 
              child: Slider(
                value: _priority,
                min: 1,
                max: 5,
                divisions: 4,
                label: _priority.toInt().toString(), 
                onChanged: (value){
                  setState(() {
                    _priority=value;
                  });
                }
              )
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Date:'),
                const SizedBox(width: 10),
                TextButton(
                  child: Text('${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
                  onPressed: ()async {
                    final picked=await showDatePicker(
                      context: context,
                      initialDate: _selectedDate, 
                      firstDate: DateTime(2000), 
                      lastDate: DateTime(2100)
                    );
                    if(picked!=null){
                      setState(()=>_selectedDate=picked);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _categories.map((cat){
                final isSelected=cat==_selectedCategory;
                return ChoiceChip(
                  label: Text(cat), 
                  selected: isSelected,
                  selectedColor: theme.colorScheme.secondaryContainer,
                  backgroundColor: theme.chipTheme.backgroundColor,
                  labelStyle: theme.chipTheme.labelStyle,
                  onSelected: (_){
                    setState(()=>_selectedCategory=cat);
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.amber[700] // or any color for dark mode
                    : Colors.black,     // or any color for light mode
              ),
              onPressed: () {
                final entry = Entry(
                  title: _titleControler.text,
                  date: _selectedDate,
                  priority: _priority.round(),
                  category: _selectedCategory,
                );
                Provider.of<EntryProvider>(context, listen: false).addEntry(entry);
              },
              child: const Text('Add Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
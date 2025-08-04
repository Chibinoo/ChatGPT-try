import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/entry_provider.dart';
import '../data/entry.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    final titleControler=TextEditingController();
    double _priority=1;//default slider value

    //Get slider color based on priority level
    Color _getSliderColor(double value){
      if(value<=2) return Colors.green; //low
      if(value<=4) return Colors.orange; //mid
      return Colors.red;//high
    }
@override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Entries'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleControler,
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
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
              onPressed: (){
                if (titleControler.text.isNotEmpty){
                  Provider.of<EntryProvider>(context, listen:false).addEntry(
                    Entry(
                      title:titleControler.text, 
                      date: DateTime.now(), 
                      priority: _priority.toInt(),
                    ),
                  );
                  titleControler.clear();
                  setState(() {
                    _priority=1;//reset slider
                  });
                }
              }, 
              child: const Text('Add Entry'),
            ),
            )
          ],
        ),
      ),
    );
  }
}
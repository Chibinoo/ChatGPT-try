import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../data/entry_provider.dart';
import '../data/entry.dart';
import 'package:path/path.dart' as path;

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
    File? _selectedImage;

    Future<void> _pickImage(ImageSource source) async{
      final picker=ImagePicker();
      final pickedFile=await picker.pickImage(source: source, imageQuality: 80);

      if(pickedFile!=null){
        setState(() {
          _selectedImage=File(pickedFile.path);
        });
      }
    }

    //handles image saving depending on mode
    Future<String?> _saveImage(File image) async{
      final isCloudMode=Provider.of<EntryProvider>(context, listen: false).isCloudMode;

      if(isCloudMode){
        //upload to firebase storage
        final storageRef=FirebaseStorage.instance.ref().child('entry_images/${DateTime.now().microsecondsSinceEpoch}.jpg');

        await storageRef.putFile(image);
        return await storageRef.getDownloadURL();
      }else{
        //Save locally
        final appDir=await getApplicationCacheDirectory();
        final fileName=path.basename(image.path);
        final savedImage=await image.copy('${appDir.path}/$fileName');
        return savedImage.path;
      }
    }

    void _saveEntry()async{
      String? imagePath;
      if(_selectedImage!=null){
        imagePath=await _saveImage(_selectedImage!);
      }
      final entry=Entry(
        title: _titleControler.text, 
        priority: _priority.round(),
        date: _selectedDate, 
        category: _selectedCategory,
        imagePath: imagePath,
      );
      // ignore: use_build_context_synchronously
      Provider.of<EntryProvider>(context, listen: false).addEntry(entry);
    }

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
            const SizedBox(height: 10),
            //image preveiw
            if(_selectedImage!=null)
              Image.file(_selectedImage!,height: 150,fit: BoxFit.cover,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: ()=>_pickImage(ImageSource.camera), 
                ),
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: ()=>_pickImage(ImageSource.gallery), 
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.white // or any color for dark mode
                    : Colors.black,     // or any color for light mode
              ),
              onPressed: _saveEntry,
              child: const Text('Add Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
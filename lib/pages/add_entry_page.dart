import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/widgets/emotion_picker_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/data/entry.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
import 'login_page.dart';

class AddEntryPage extends StatefulWidget {
  final Entry? existingEntry; //null if creating new

  const AddEntryPage({super.key, this.existingEntry});

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final TextEditingController _titleControler = TextEditingController();
  double _priority = 3;
  String _category = 'Other';
  String? _imagePath;
  String? _emotion;

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _titleControler.text = widget.existingEntry!.title;
      _priority = widget.existingEntry!.priority.toDouble();
      _category = widget.existingEntry!.category;
      _imagePath = widget.existingEntry!.imagePath;
      _emotion=widget.existingEntry!.emotion;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (_titleControler.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title cannot be empty')));
      return;
    }

    final provider = Provider.of<EntryProvider>(context, listen: false);

    if (widget.existingEntry != null) {
      // Update existing entry
      widget.existingEntry!
        ..title = _titleControler.text
        ..priority = _priority.round()
        ..category = _category
        ..imagePath = _imagePath
        ..emotion=_emotion;
      await provider.updateEntry(widget.existingEntry!);
    } else {
      // Create new
      final newEntry = Entry(
        title: _titleControler.text,
        date: provider.currentTime,
        priority: _priority.round(),
        category: _category,
        imagePath: _imagePath,
        emotion: _emotion,
      );
      await provider.addEntry(newEntry);
    }
    //emotionPicker
    final emotion = await Navigator.push<String>(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (_) => const EmotionPickerPage()),
    );
    if (emotion != null) {}
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/main');
  }

  Widget _buildCategorySelector() {
    final categories = ["Work", "Hobby", "Personal", "Other"];
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      children: categories.map((cat) {
        final isSelected = _category == cat;
        return ChoiceChip(
          label: Text(cat),
          selected: isSelected,
          labelStyle: TextStyle(color: isSelected? theme.colorScheme.primary
                      : theme.colorScheme.tertiary,),
          onSelected: (_) => setState(() => _category = cat),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(
      context,
    ); // <-- Add this line

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingEntry == null ? "Add Entry" : "Edit Entry"),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              if (user == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              } else {
                FirebaseAuth.instance.signOut();
              }
            },
            icon: Icon(
              user == null ? Icons.login : Icons.logout,
              color: theme.colorScheme.tertiary, // Use theme color here
            ),
            label: Text(
              user == null ? 'Login' : 'Logout',
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.white
                    : Colors.black, // Use themeProvider here
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Titel
            TextField(
              controller: _titleControler,
              decoration: const InputDecoration(
                labelText: "Titel",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            //Priority Slider
            Text(
              "Priority: ${_priority.round()}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _priority,
              min: 1,
              max: 5,
              divisions: 4,
              label: _priority.round().toString(),
              onChanged: (val) => setState(() => _priority = val),
            ),
            const SizedBox(height: 20),
            //Category selector
            const Text(
              "Category",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildCategorySelector(),
            const SizedBox(height: 20),
            //emotionPicker
const SizedBox(height: 20),
const Text(
  "How are you feeling?",
  style: TextStyle(fontWeight: FontWeight.bold),
),
const SizedBox(height: 10),
GestureDetector(
  onTap: () async {
    final emotion = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const EmotionPickerPage()),
    );
    if (emotion != null) {
      setState(() => _emotion = emotion);
    }
  },
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(Icons.emoji_emotions_outlined),
        const SizedBox(width: 12),
        Text(
          _emotion ?? 'Tap to select an emotion',
          style: TextStyle(
            color: _emotion != null ? null : Colors.grey,
          ),
        ),
        const Spacer(),
        if (_emotion != null)
          const Icon(Icons.check_circle, color: Colors.green),
      ],
    ),
  ),
),
            //Image picker
            if (_imagePath != null)
              Center(
                child: Image.file(
                  File(_imagePath!),
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                ),
                IconButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  foregroundColor: themeProvider.isDarkMode
                      ? theme.colorScheme.primary
                      : theme.colorScheme.tertiary,
                ),
                onPressed: _saveEntry,
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  foregroundColor: themeProvider.isDarkMode
                      ? theme.colorScheme.primary
                      : theme.colorScheme.tertiary,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/main');
                },
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

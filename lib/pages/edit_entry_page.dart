import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/data/entry.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';

class EditEntryPage extends StatefulWidget {
  final Entry existingEntry; // Now required and non-nullable

  const EditEntryPage({super.key, required this.existingEntry});

  @override
  State<EditEntryPage> createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  final TextEditingController _titleControler = TextEditingController();
  double _priority = 3;
  String _category = 'Other';
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    // No null checks needed, always editing an existing entry
    _titleControler.text = widget.existingEntry.title;
    _priority = widget.existingEntry.priority.toDouble();
    _category = widget.existingEntry.category;
    _imagePath = widget.existingEntry.imagePath;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final provider = Provider.of<EntryProvider>(context, listen: false);

    widget.existingEntry
      ..title = _titleControler.text
      ..priority = _priority.round()
      ..category = _category
      ..imagePath = _imagePath;
    await provider.updateEntry(widget.existingEntry);

    // ignore: use_build_context_synchronously
    Navigator.pop(context); // <-- Close the page
  }

  Widget _buildCategorySelector() {
    final categories = ["Work", "Hobby", "Personal", "Other"];
    return Wrap(
      spacing: 8,
      children: categories.map((cat) {
        final isSelected = _category == cat;
        return ChoiceChip(
          label: Text(cat),
          selected: isSelected,
          onSelected: (_) => setState(() => _category = cat),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Entry"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleControler,
              decoration: const InputDecoration(
                labelText: "Titel",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Priority Slider
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
            // Category selector
            const Text(
              "Category",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildCategorySelector(),
            const SizedBox(height: 20),
            // Image picker
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
                  icon: const Icon(Icons.photo_library),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  foregroundColor: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black,
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
                  foregroundColor: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context); // <-- Close the page
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
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/edit_numbered_list_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/entry_provider.dart';

class NumberedListWidget extends StatefulWidget {
  const NumberedListWidget({super.key});

  @override
  State<NumberedListWidget> createState() => _NumberedListWidgetState();
}

class _NumberedListWidgetState extends State<NumberedListWidget> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  void _syncControllers(List<String> items) {
    // Add controllers and focus nodes if needed
    while (_controllers.length < items.length) {
      _controllers.add(TextEditingController(text: items[_controllers.length]));
      _focusNodes.add(FocusNode());
    }
    // Remove controllers and focus nodes if needed
    while (_controllers.length > items.length) {
      _controllers.removeLast().dispose();
      _focusNodes.removeLast().dispose();
    }
    // Only update controller text if its own node is not focused
    for (int i = 0; i < items.length; i++) {
      final controller = _controllers[i];
      final focusNode = _focusNodes[i];
      // Only update if not focused and text is different
      if (!focusNode.hasFocus && controller.text != items[i]) {
        controller.text = items[i];
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EntryProvider>(
      builder: (context, provider, _) {
        if (!provider.listEnabled) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Numbered List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditNumberedListPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...provider.numberedItems.asMap().entries.map((entry) {
              final index = entry.key;
              final title = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5), // Increase vertical space
                child: Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: const TextStyle(fontSize: 18), // Bigger number
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 18), // Bigger text
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
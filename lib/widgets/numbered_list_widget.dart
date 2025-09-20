import 'package:flutter/material.dart';
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
        _syncControllers(provider.numberedItems);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Numbered List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // ignore: sized_box_for_whitespace
            ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  provider.reorderItems(oldIndex, newIndex);
                  setState(() {});
                },
                children: [
                  for (int index = 0; index < provider.numberedItems.length; index++)
                    ListTile(
                      key: ValueKey('item_$index'),
                      leading: Text('${index + 1}.'),
                      title: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) {
                          provider.updateItem(index, value);
                        },
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.removeItem(index);
                          setState(() {});
                        },
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                provider.addItem();
                setState(() {});
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        );
      },
    );
  }
}
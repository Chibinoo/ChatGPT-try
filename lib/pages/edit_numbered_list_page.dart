import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/entry_provider.dart';

class EditNumberedListPage extends StatefulWidget {
  const EditNumberedListPage({super.key});

  @override
  State<EditNumberedListPage> createState() => _EditNumberedListPageState();
}

class _EditNumberedListPageState extends State<EditNumberedListPage> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final items =
        Provider.of<EntryProvider>(context, listen: false).numberedItems;
    _controllers = items.map((e) => TextEditingController(text: e)).toList();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final provider = Provider.of<EntryProvider>(context, listen: false);
    provider.numberedItems = _controllers.map((c) => c.text).toList();
    provider.saveNumberedItems();
    Navigator.of(context).pop();
  }

  void _addItem() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _controllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Numbered List'),
      ),
      body: _controllers.isEmpty
          ? const Center(child: Text('No items yet. Tap + Add Item.'))
          : ReorderableListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final c = _controllers.removeAt(oldIndex);
                  _controllers.insert(newIndex, c);
                });
              },
              children: [
                for (int i = 0; i < _controllers.length; i++)
                  Container(
                    key: ValueKey('item_$i'),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.primary),
                    ),
                    child: ListTile(
                      key: ValueKey('list_tile_$i'),
                      leading: Text('${i + 1}.',
                          style: TextStyle(color: textColor)),
                      title: TextField(
                        controller: _controllers[i],
                        decoration: InputDecoration(
                          hintText: 'Enter item ${i + 1}',
                          hintStyle:
                              TextStyle(color: textColor),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: textColor),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: colorScheme.error),
                            onPressed: () => _removeItem(i),
                          ),
                          const Icon(Icons.drag_handle),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _addItem,
            heroTag: 'add_item',
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: _save,
            heroTag: 'save_list',
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

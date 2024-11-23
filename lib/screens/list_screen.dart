import 'package:flutter/material.dart';
import '../models/list_model.dart';
import '../models/item_model.dart';
import '../services/storage_service.dart';

class ListScreen extends StatefulWidget {
  final ListModel listModel;

  const ListScreen({required this.listModel, super.key});

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late ListModel _listModel;
  final TextEditingController _textController = TextEditingController(); // Controller for the text field

  @override
  void initState() {
    super.initState();
    _listModel = widget.listModel;
  }

  void _addItem() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _listModel.items.add(ItemModel(text: _textController.text));
        _textController.clear(); // Clear the input field after adding
      });
      _saveList();
    }
  }

  void _deleteItem(int index) {
    setState(() {
      _listModel.items.removeAt(index);
    });
    _saveList();
  }

  void _toggleCompletion(int index) {
    setState(() {
      _listModel.items[index] = ItemModel(
        text: _listModel.items[index].text,
        isCompleted: !_listModel.items[index].isCompleted,
      );
    });
    _saveList();
  }

  Future<void> _saveList() async {
    await StorageService.writeList(_listModel);
  }

  @override
  Widget build(BuildContext context) {
    // Sort items: incomplete first, then complete
    final sortedItems = [
      ..._listModel.items.where((item) => !item.isCompleted), // Incomplete
      ..._listModel.items.where((item) => item.isCompleted), // Complete
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_listModel.name),
      ),
      body: Column(
        children: [
          // Input field for new items
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController, // Attach the controller
                    decoration: const InputDecoration(
                      labelText: 'New Item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      _addItem(); // Add the item when Enter is pressed
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addItem, // Add the new item
                ),
              ],
            ),
          ),
          // List of items
          Expanded(
            child: ListView.builder(
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final item = sortedItems[index];
                return ListTile(
                  leading: IconButton(
                    icon: Icon(
                      item.isCompleted
                          ? Icons.check_circle // Full sirkel for fullført
                          : Icons.radio_button_unchecked, // Tom sirkel for ikke-fullført
                      color: item.isCompleted ? Colors.green : Colors.grey,
                    ),
                    onPressed: () => _toggleCompletion(
                        _listModel.items.indexOf(item)), // Toggle status
                  ),
                  title: Text(
                    item.text,
                    style: TextStyle(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough // Strek gjennom for fullførte
                          : TextDecoration.none, // Ingen stil for ikke-fullførte
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _deleteItem(_listModel.items.indexOf(item)), // Delete the item
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

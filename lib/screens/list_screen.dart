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
  final TextEditingController _textController = TextEditingController(); // Controller for text field
  final FocusNode _focusNode = FocusNode(); // FocusNode for managing focus on the input field for newe items

  @override
  void initState() {
    super.initState();
    _listModel = widget.listModel;
    _listModel.items = List.from(_listModel.items); // Convert to mutable list
    _textController.addListener(_updateAddButtonState); // Listener for input field
  }

  @override
  void dispose() {
    _textController.dispose(); // Dispose of controller
    _focusNode.dispose(); // Dispose of focus node
    super.dispose();
  }

  void _updateAddButtonState() {
    setState(() {}); // Trigger rebuild to update button state and color
  }

  void _addItem() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _listModel.items.add(
          ItemModel.newItem(text: _textController.text), // Use factory method for creating new item
        );
        _textController.clear(); // Clear the input field
      });
      _saveList();

      // Refocus to text field input on top of list
      _focusNode.requestFocus();
    }
  }

  // TODO RC2 Add confirmation for deletion of list item
  // Delete list item
  void _deleteItem(int index) {
    setState(() {
      _listModel.items.removeAt(index);
    });
    _saveList();
  }

  // Mark/toggle item as complete or incomplete
  void _toggleCompletion(int index) {
    setState(() {
      _listModel.items[index] = ItemModel(
        id: _listModel.items[index].id,
        text: _listModel.items[index].text,
        isCompleted: !_listModel.items[index].isCompleted,
      );
    });
    _saveList();
  }

  // Save list to file
  Future<void> _saveList() async {
    await StorageService.writeList(_listModel);
  }

  // Building the list screen
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
                    controller: _textController,
                    focusNode: _focusNode, // Attach the focus node
                    decoration: const InputDecoration(
                      labelText: 'New Item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      _addItem(); // Add the item when Enter is pressed
                    },
                  ),
                ),
                const SizedBox(width: 8), // Add padding between TextField and button
                Material(
                  elevation: _textController.text.isNotEmpty ? 6.0 : 0.0, // Higher elevation for active state
                  shape: const CircleBorder(),
                  color: _textController.text.isNotEmpty ? Colors.blue : Colors.grey, // Background color
                  child: SizedBox(
                    width: 40, // Adjust button width
                    height: 40, // Adjust button height
                    child: IconButton(
                      iconSize: 20, // Reduce the size of the icon itself
                      icon: const Icon(Icons.add),
                      color: Colors.white, // Icon color
                      onPressed: _textController.text.isNotEmpty
                          ? _addItem // Add the new item
                          : null, // Disable button when field is empty
                    ),
                  ),
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
                          ? Icons.check_circle // Filled circle for complete
                          : Icons.radio_button_unchecked, // Empty circle for incomplete
                      color: item.isCompleted ? Colors.green : Colors.grey,
                    ),
                    onPressed: () => _toggleCompletion(
                        _listModel.items.indexOf(item)), // Toggle status
                  ),
                  title: Text(
                    item.text,
                    style: TextStyle(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough // Strike-through for completed
                          : TextDecoration.none, // PLain text for incomplete
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _deleteItem(_listModel.items.indexOf(item)), // Delete the item
                  ),
                  onTap: () => _toggleCompletion(
                      _listModel.items.indexOf(item)), // Mark complete/incomplete on tap
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

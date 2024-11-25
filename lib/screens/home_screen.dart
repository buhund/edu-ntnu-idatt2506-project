import 'package:flutter/material.dart';
import '../models/list_model.dart';
import '../services/storage_service.dart';
import 'list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ListModel> _lists = [];
  final TextEditingController _textController = TextEditingController(); // Controller for input field

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    final loadedLists = await StorageService.readAllLists();
    setState(() {
      _lists = loadedLists;
    });
  }

  Future<void> _addNewList(String listName) async {
    // Error if list with same name already exists
    if (_lists.any((list) => list.name == listName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A list with this name already exists')),
      );
      return;
    }

    final newList = ListModel.newList(name: listName); // Use factory method for creating new list
    setState(() {
      _lists.add(newList);
    });
    await StorageService.writeList(newList); // Save to a separate file
  }

  // TODO RC2 Add confirmation for deletion of list item
  Future<void> _deleteList(int index) async {
    final list = _lists[index];
    setState(() {
      _lists.removeAt(index);
    });
    await StorageService.deleteList(list.name, list.id);
  }

  void _handleAddList() {
    if (_textController.text.isNotEmpty) {
      _addNewList(_textController.text); // Add new list via bottom input field
      _textController.clear(); // Empty textfield on submit
      FocusScope.of(context).requestFocus(FocusNode()); // Refocus input field
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('List name cannot be empty')),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose(); // Clean up text controller
    super.dispose();
  }

  // Add new list via + button and dialog
  // Replaced (at least for now) by the input field at the bottom of the screen
  void _showAddListDialog() {
    String newListName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New List'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'List Name'),
            onChanged: (value) {
              newListName = value;
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (newListName.isNotEmpty) {
                  _addNewList(newListName); // Add the list
                }
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        actions: [
          // Add list via + button and dialog. Not as per assignment spec
          /**IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddListDialog();
            },
          ),*/
        ],
      ),
      body: Column(
        children: [
          // Display lists
          Expanded(
            child: ListView.builder(
              itemCount: _lists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_lists[index].name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteList(index),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListScreen(listModel: _lists[index]),
                      ),
                    ).then((_) {
                      _loadLists(); // Reload lists when returning from ListScreen
                    });
                  },
                );
              },
            ),
          ),
          // Input field for adding new lists, as per assignment spec
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Add New List',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Update button color on text change
                    },
                    onSubmitted: (value) => _handleAddList(), // Handle Enter key
                  ),
                ),
                const SizedBox(width: 8), // Add padding between TextField and button
                Material(
                  elevation: _textController.text.isNotEmpty ? 6.0 : 0.0, // Elevation for active state
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
                          ? _handleAddList // Activate button only when text is present
                          : null, // Disable button when text is empty
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

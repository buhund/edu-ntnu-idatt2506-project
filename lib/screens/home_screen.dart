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
    final newList = ListModel.newList(name: listName); // Use factory method for creating new list
    setState(() {
      _lists.add(newList);
    });
    await StorageService.writeList(newList); // Save to a separate file
  }

  Future<void> _deleteList(int index) async {
    final list = _lists[index];
    setState(() {
      _lists.removeAt(index);
    });
    await StorageService.deleteList(list.name, list.id);
  }


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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddListDialog();
            },
          ),
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
        ],
      ),
    );
  }
}

// lib/screens/home_screen.dart

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
    final loadedLists = await StorageService.readLists();
    setState(() {
      _lists = loadedLists;
    });
  }

  Future<void> _addNewList(String listName) async {
    final newList = ListModel(name: listName);
    setState(() {
      _lists.add(newList);
    });
    await StorageService.writeLists(_lists);
  }

  Future<void> _deleteList(int index) async {
    setState(() {
      _lists.removeAt(index);
    });
    await StorageService.writeLists(_lists);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
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
          // Add new list
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'New List',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _addNewList(value);
                      }
                    },
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

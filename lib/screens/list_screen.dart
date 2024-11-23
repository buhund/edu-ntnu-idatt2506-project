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

  @override
  void initState() {
    super.initState();
    _listModel = widget.listModel;
  }

  void _addItem(String text) {
    setState(() {
      _listModel.items.add(ItemModel(text: text));
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
    print('Saving list: ${_listModel.name}');
    final lists = await StorageService.readLists();
    final index = lists.indexWhere((list) => list.name == _listModel.name);
    if (index != -1) {
      lists[index] = _listModel;
    }
    await StorageService.writeLists(lists);
  }


  @override
  Widget build(BuildContext context) {
    final completedItems = _listModel.items.where((item) => item.isCompleted).toList();
    final incompleteItems = _listModel.items.where((item) => !item.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_listModel.name),
      ),
      body: Column(
        children: [
          // Input field for new items
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'New Item',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _addItem(value);
                }
              },
            ),
          ),
          // List of items
          Expanded(
            child: ListView(
              children: [
                // Incomplete items
                ...incompleteItems.map((item) => ListTile(
                  title: Text(item.text),
                  onTap: () => _toggleCompletion(_listModel.items.indexOf(item)),
                )),
                const Divider(),
                // Completed items
                ...completedItems.map((item) => ListTile(
                  title: Text(
                    item.text,
                    style: const TextStyle(decoration: TextDecoration.lineThrough),
                  ),
                  onTap: () => _toggleCompletion(_listModel.items.indexOf(item)),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

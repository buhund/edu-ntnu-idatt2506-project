// lib/models/list_model.dart

import 'item_model.dart';
import 'package:uuid/uuid.dart';

class ListModel {
  final String id;
  final String name;
  List<ItemModel> items;

  ListModel({
    required this.id,
    required this.name,
    List<ItemModel>? items})
      : items = items ?? []; // Initialize as a mutable list

  // Convert ListModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Create ListModel from JSON
  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['id'],
      name: json['name'],
      items: (json['items'] as List)
          .map((item) => ItemModel.fromJson(item))
          .toList(),
    );
  }


  // Fancy Factory for creating new list with unique ID
  factory ListModel.newList({required String name}) {
    return ListModel(
      id: const Uuid().v4(),
      name: name,
    );
  }
}


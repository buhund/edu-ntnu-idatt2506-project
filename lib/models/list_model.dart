// lib/models/list_model.dart

import 'item_model.dart';

class ListModel {
  final String name;
  List<ItemModel> items;

  ListModel({required this.name, List<ItemModel>? items})
      : items = items ?? []; // Initialize as a mutable list

  // Convert ListModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Create ListModel from JSON
  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      name: json['name'],
      items: (json['items'] as List)
          .map((item) => ItemModel.fromJson(item))
          .toList(),
    );
  }
}


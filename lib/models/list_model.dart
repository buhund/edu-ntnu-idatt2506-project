import 'item_model.dart';

class ListModel {
  final String name;
  final List<ItemModel> items;

  ListModel({required this.name, this.items = const []});

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

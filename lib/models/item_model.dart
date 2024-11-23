// lib/models/list_model.dart
import 'package:uuid/uuid.dart';


class ItemModel {
  final String id;
  final String text;
  final bool isCompleted;

  ItemModel({
    required this.id,
    required this.text,
    this.isCompleted = false

  });

  // Convert ItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted,
    };
  }

  // Create ItemModel from JSON
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      text: json['text'],
      isCompleted: json['isCompleted'],
    );
  }

  // Fancy Factory for creating new item with unique ID
  factory ItemModel.newItem({required String text}) {
    return ItemModel(
      id: const Uuid().v4(),
      text: text,
    );
  }
}

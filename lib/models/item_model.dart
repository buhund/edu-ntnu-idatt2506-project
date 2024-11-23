class ItemModel {
  final String text;
  final bool isCompleted;

  ItemModel({required this.text, this.isCompleted = false});

  // Convert ItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCompleted': isCompleted,
    };
  }

  // Create ItemModel from JSON
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      text: json['text'],
      isCompleted: json['isCompleted'],
    );
  }
}

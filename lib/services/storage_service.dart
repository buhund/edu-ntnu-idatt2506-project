import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import '../models/list_model.dart';

class StorageService {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();



    // Add lists to subdir for the app
    final path = '${directory.path}/todo_app/';

    // Ensure the directory exists
    final appDir = Directory(path);
    if (!(await appDir.exists())) {
      await appDir.create(recursive: true); // Create the directory if it doesn't exist
    }

    log('Application directory: ${directory.path}'); // Debug log for base directory
    log('todo_app directory: $path'); // Debug log for todo_app directory

    return path;
    //return directory.path;
  }

  // Get a specific file for a list
  // Maybe add prefix to the file name. Maybe not needed when using a subdir.
  // I shall have think about it!
  static Future<File> _listFile(String listName) async {
    final path = await _localPath;
    final sanitizedFileName = listName.replaceAll(RegExp(r'[^\w\s]+'), '_'); // Sanitize name
    return File('$path/$sanitizedFileName.json');
  }

  // Save a single list to its own JSON file
  static Future<void> writeList(ListModel list) async {
    final file = await _listFile(list.name);
    final json = jsonEncode(list.toJson());
    log('Saving list to: ${file.path}'); // Debug log
    await file.writeAsString(json);
  }

  // Read a single list from its JSON file
  static Future<ListModel?> readList(String listName) async {
    try {
      final file = await _listFile(listName);
      if (await file.exists()) {
        final contents = await file.readAsString();
        final json = jsonDecode(contents);
        return ListModel.fromJson(json);
      }
      return null;
    } catch (e) {
      log('Error reading list: $e');
      return null;
    }
  }

  // Load all JSON files in the directory
  static Future<List<ListModel>> readAllLists() async {
    try {
      final path = await _localPath;
      final directory = Directory(path);
      final files = directory.listSync().where((file) => file.path.endsWith('.json'));
      List<ListModel> lists = [];
      for (var file in files) {
        final contents = await File(file.path).readAsString();
        final json = jsonDecode(contents);
        lists.add(ListModel.fromJson(json));
      }
      return lists;
    } catch (e) {
      log('Error loading all lists: $e');
      return [];
    }
  }

  // Delete a specific list's JSON file
  static Future<void> deleteList(String listName) async {
    final file = await _listFile(listName);
    if (await file.exists()) {
      await file.delete();
      log('Deleted list file: ${file.path}');
    }
  }
}

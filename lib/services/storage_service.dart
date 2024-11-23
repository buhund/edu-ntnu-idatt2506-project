// lib/services/storage_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:developer'; // For logging

import 'package:path_provider/path_provider.dart';
import '../models/list_model.dart';

class StorageService {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName.json');
  }


  static Future<void> writeLists(List<ListModel> lists) async {
    final file = await _localFile('lists');
    log('Saving lists to: ${file.path}'); // Debug log
    final json = jsonEncode(lists.map((e) => e.toJson()).toList());
    await file.writeAsString(json);
  }

  static Future<List<ListModel>> readLists() async {
    try {
      final file = await _localFile('lists');
      log('Reading lists from: ${file.path}'); // Debug log
      if (await file.exists()) {
        final contents = await file.readAsString();
        log('File contents: $contents'); // Debug log
        final json = jsonDecode(contents) as List;
        return json.map((e) => ListModel.fromJson(e)).toList();
      } else {
        log('File does not exist'); // Debug log
        return [];
      }
    } catch (e) {
      log('Error reading file: $e'); // Debug log
      return [];
    }
  }

}


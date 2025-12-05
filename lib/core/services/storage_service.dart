import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._internal();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  StorageService._internal();

  // Save string
  Future<bool> saveString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  // Get string
  String? getString(String key) {
    return _prefs!.getString(key);
  }

  // Save list of strings
  Future<bool> saveStringList(String key, List<String> value) async {
    return await _prefs!.setStringList(key, value);
  }

  // Get list of strings
  List<String>? getStringList(String key) {
    return _prefs!.getStringList(key);
  }

  // Save bool
  Future<bool> saveBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }

  // Get bool
  bool? getBool(String key) {
    return _prefs!.getBool(key);
  }

  // Save int
  Future<bool> saveInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }

  // Get int
  int? getInt(String key) {
    return _prefs!.getInt(key);
  }

  // Save double
  Future<bool> saveDouble(String key, double value) async {
    return await _prefs!.setDouble(key, value);
  }

  // Get double
  double? getDouble(String key) {
    return _prefs!.getDouble(key);
  }

  // Save object as JSON
  Future<bool> saveObject(String key, Map<String, dynamic> value) async {
    String jsonString = jsonEncode(value);
    return await _prefs!.setString(key, jsonString);
  }

  // Get object from JSON
  Map<String, dynamic>? getObject(String key) {
    String? jsonString = _prefs!.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Remove value
  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  // Clear all values
  Future<bool> clear() async {
    return await _prefs!.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs!.containsKey(key);
  }
}
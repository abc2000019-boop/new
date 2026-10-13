import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';
import '../utils/constants.dart';

class StorageService {
  static Future<void> saveDevices(List<Device> devices) async {
    final prefs = await SharedPreferences.getInstance();
    final data = devices.map((d) => d.toJson()).toList();
    await prefs.setString(AppConstants.keyDevices, jsonEncode(data));
  }

  static Future<List<Device>> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.keyDevices);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Device.fromJson(e)).toList();
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleLocale extends ChangeNotifier {
  static const String _prefsKey = 'app_locale_code';

  String _code = 'bm'; // default: Bambara
  String get code => _code;

  bool _notificationsEnabled = true;
  bool _isInitialized = false;

  // Method to temporarily disable notifications (e.g., during text input)
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
  }

  // Check if the provider is initialized
  bool get isInitialized => _isInitialized;

  Future<void> load() async {
    if (_isInitialized) return; // Prevent multiple loads

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null && saved.isNotEmpty) {
        _code = saved;
      }
      _isInitialized = true;
      if (_notificationsEnabled) {
        notifyListeners();
      }
    } catch (_) {
      // ignore read errors; keep default
      _isInitialized = true;
    }
  }

  Future<void> setCode(String newCode) async {
    if (newCode == _code) return; // No change needed

    _code = newCode;

    // Only notify if notifications are enabled and initialized
    if (_notificationsEnabled && _isInitialized) {
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, newCode);
    } catch (_) {
      // ignore write errors
    }
  }

  // Method to force a rebuild (use sparingly)
  void forceRebuild() {
    if (_notificationsEnabled) {
      notifyListeners();
    }
  }
}

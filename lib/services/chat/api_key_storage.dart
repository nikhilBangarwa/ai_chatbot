import 'package:shared_preferences/shared_preferences.dart';

/// Persists Groq API key — loaded once, available on every chat screen visit.
class ApiKeyStorage {
  ApiKeyStorage._();
  static const _key = 'groq_api_key';

  static Future<String> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? '';
  }

  static Future<void> save(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, apiKey.trim());
  }

  static Future<bool> hasKey() async {
    final key = await load();
    return key.isNotEmpty;
  }
}

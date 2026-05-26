import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Loads the shared Groq API key from Firebase (set once by you in Console).
/// End users never enter or see the key.
class GroqConfigService {
  GroqConfigService._();

  static const String collection = 'app_config';
  static const String documentId = 'groq';
  static const String apiKeyField = 'apiKey';

  static String? _cachedKey;

  /// Build-time override: flutter run --dart-define=GROQ_API_KEY=gsk_xxx
  static const String _envKey = String.fromEnvironment('GROQ_API_KEY');

  static Future<String> loadApiKey() async {
    if (_cachedKey != null && _cachedKey!.isNotEmpty) {
      return _cachedKey!;
    }

    if (_envKey.isNotEmpty) {
      _cachedKey = _envKey;
      return _envKey;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(documentId)
          .get();

      final key = (doc.data()?[apiKeyField] as String?)?.trim() ?? '';
      if (key.isNotEmpty) {
        _cachedKey = key;
        return key;
      }
    } catch (e) {
      debugPrint('GroqConfigService: failed to load key — $e');
    }

    return '';
  }

  static void clearCache() => _cachedKey = null;
}

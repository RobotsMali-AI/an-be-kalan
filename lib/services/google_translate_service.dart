import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service to handle Google Translate API calls
class GoogleTranslateService {
  static final GoogleTranslateService _instance =
      GoogleTranslateService._internal();
  factory GoogleTranslateService() => _instance;
  GoogleTranslateService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _cachedApiKey;

  /// Fetches the Google Translate API key from Firestore
  Future<String> _getApiKey() async {
    if (_cachedApiKey != null) {
      return _cachedApiKey!;
    }

    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('api').doc('google-api').get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('Google API key document not found in Firestore');
      }

      final key = doc.data()!['key'];
      if (key == null || key.isEmpty) {
        throw Exception('Google API key is empty or null');
      }

      _cachedApiKey = key;
      return key;
    } catch (e) {
      throw Exception('Failed to fetch Google API key: $e');
    }
  }

  /// Translates text using Google Translate API
  ///
  /// Parameters:
  /// - [text]: The text to translate
  /// - [sourceLanguage]: Source language code (e.g., 'en', 'fr', 'bm')
  /// - [targetLanguage]: Target language code (e.g., 'en', 'fr', 'bm')
  ///
  /// Returns the translated text
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (text.trim().isEmpty) {
      return text;
    }

    if (sourceLanguage == targetLanguage) {
      return text;
    }

    try {
      final apiKey = await _getApiKey();
      final url = Uri.parse(
        'https://translation.googleapis.com/language/translate/v2?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'source': sourceLanguage,
          'target': targetLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText =
            data['data']['translations'][0]['translatedText'];
        return translatedText;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Translation failed: ${errorData['error']['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      if (e.toString().contains('Failed to fetch Google API key')) {
        rethrow;
      }
      throw Exception('Translation error: $e');
    }
  }

  /// Clears the cached API key (useful for testing or if key is updated)
  void clearCache() {
    _cachedApiKey = null;
  }

  /// Batch translate multiple texts at once
  ///
  /// Parameters:
  /// - [texts]: List of texts to translate
  /// - [sourceLanguage]: Source language code
  /// - [targetLanguage]: Target language code
  ///
  /// Returns list of translated texts
  Future<List<String>> batchTranslate({
    required List<String> texts,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (texts.isEmpty) {
      return [];
    }

    if (sourceLanguage == targetLanguage) {
      return texts;
    }

    try {
      final apiKey = await _getApiKey();
      final url = Uri.parse(
        'https://translation.googleapis.com/language/translate/v2?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': texts,
          'source': sourceLanguage,
          'target': targetLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translations = (data['data']['translations'] as List)
            .map((t) => t['translatedText'] as String)
            .toList();
        return translations;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Batch translation failed: ${errorData['error']['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      if (e.toString().contains('Failed to fetch Google API key')) {
        rethrow;
      }
      throw Exception('Batch translation error: $e');
    }
  }
}

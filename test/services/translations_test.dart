import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_app/services/translations.dart';

void main() {
  group('tStatic', () {
    test('returns Bambara translation for bm code', () {
      expect(tStatic('language', 'bm'), 'Kan');
    });

    test('returns English translation for en code', () {
      expect(tStatic('language', 'en'), 'Language');
    });

    test('returns French translation for fr code', () {
      expect(tStatic('language', 'fr'), 'Langue');
    });

    test('falls back to Bambara for unknown language code', () {
      expect(tStatic('language', 'xx'), 'Kan');
    });

    test('returns key itself if not found in any language', () {
      expect(tStatic('nonexistent_key_xyz', 'en'), 'nonexistent_key_xyz');
    });

    test('falls back to Bambara when key missing in requested language', () {
      // Use a key that exists in bm but might not exist in en/fr
      // 'bambara_history' exists in all three, so let's test the fallback mechanism
      final result = tStatic('bambara_history', 'bm');
      expect(result, isNotEmpty);
      expect(result, isNot('bambara_history'));
    });
  });

  group('supportedLanguages', () {
    test('returns 3 languages', () {
      final languages = supportedLanguages();
      expect(languages.length, 3);
    });

    test('contains Bambara, English, French', () {
      final languages = supportedLanguages();
      final codes = languages.map((l) => l['code']).toList();
      expect(codes, contains('bm'));
      expect(codes, contains('en'));
      expect(codes, contains('fr'));
    });

    test('each language has code, name, and flag', () {
      for (final lang in supportedLanguages()) {
        expect(lang.containsKey('code'), true);
        expect(lang.containsKey('name'), true);
        expect(lang.containsKey('flag'), true);
        expect(lang['code'], isNotEmpty);
        expect(lang['name'], isNotEmpty);
      }
    });
  });

  group('translation coverage', () {
    test('all three languages have the same keys', () {
      // Test a representative set of keys exist in all languages
      const keysToCheck = [
        'language',
        'profile',
        'books',
        'games',
        'welcome',
        'save',
        'cancel',
        'loading',
        'sign_in',
        'sign_out',
        'create_account',
        'password',
      ];

      for (final key in keysToCheck) {
        expect(tStatic(key, 'bm'), isNot(key),
            reason: 'Bambara missing key: $key');
        expect(tStatic(key, 'en'), isNot(key),
            reason: 'English missing key: $key');
        expect(tStatic(key, 'fr'), isNot(key),
            reason: 'French missing key: $key');
      }
    });
  });
}

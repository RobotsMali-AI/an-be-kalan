import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_app/services/simple_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SimpleLocale', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to Bambara (bm)', () {
      final locale = SimpleLocale();
      expect(locale.code, 'bm');
    });

    test('isInitialized is false before load()', () {
      final locale = SimpleLocale();
      expect(locale.isInitialized, false);
    });

    test('isInitialized is true after load()', () async {
      final locale = SimpleLocale();
      await locale.load();
      expect(locale.isInitialized, true);
    });

    test('load() reads saved locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'fr'});

      final locale = SimpleLocale();
      await locale.load();

      expect(locale.code, 'fr');
    });

    test('load() keeps default if no saved value', () async {
      SharedPreferences.setMockInitialValues({});

      final locale = SimpleLocale();
      await locale.load();

      expect(locale.code, 'bm');
    });

    test('setCode changes the locale', () async {
      final locale = SimpleLocale();
      await locale.load();

      await locale.setCode('en');

      expect(locale.code, 'en');
    });

    test('setCode persists to SharedPreferences', () async {
      final locale = SimpleLocale();
      await locale.load();

      await locale.setCode('fr');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale_code'), 'fr');
    });

    test('setCode does nothing when same code', () async {
      final locale = SimpleLocale();
      await locale.load();

      // Track if notifyListeners was called
      int notifyCount = 0;
      locale.addListener(() => notifyCount++);

      await locale.setCode('bm'); // Same as default

      expect(notifyCount, 0);
    });

    test('load() prevents multiple loads', () async {
      final locale = SimpleLocale();
      await locale.load();
      await locale.setCode('en');
      await locale.load(); // Second load should be no-op

      expect(locale.code, 'en'); // Should keep 'en', not reload 'bm'
    });

    test('setNotificationsEnabled controls notify behavior', () async {
      final locale = SimpleLocale();
      await locale.load();

      int notifyCount = 0;
      locale.addListener(() => notifyCount++);

      locale.setNotificationsEnabled(false);
      await locale.setCode('fr');

      expect(locale.code, 'fr'); // Code still changes
      expect(notifyCount, 0); // But no notification fired
    });
  });
}

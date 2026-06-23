import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_app/models/page.dart';

void main() {
  group('Page', () {
    test('fromSnapshot parses valid data', () {
      final snapshot = {
        'image': 'page1.jpg',
        'sentences': [
          {'text': 'Hello', 'audio': 'hello.mp3'},
          {'text': 'World', 'audio': 'world.mp3'},
        ],
      };

      final page = Page.fromSnapshot(snapshot);

      expect(page.imageUrl, 'page1.jpg');
      expect(page.sentences.length, 2);
      expect(page.sentences[0].text, 'Hello');
      expect(page.sentences[1].audio, 'world.mp3');
    });

    test('fromSnapshot handles missing sentences', () {
      final snapshot = {'image': 'page.jpg'};

      final page = Page.fromSnapshot(snapshot);

      expect(page.imageUrl, 'page.jpg');
      expect(page.sentences, isEmpty);
    });

    test('fromSnapshot handles missing image', () {
      final snapshot = {
        'sentences': [
          {'text': 'Test', 'audio': 'test.mp3'},
        ],
      };

      final page = Page.fromSnapshot(snapshot);

      expect(page.imageUrl, '');
      expect(page.sentences.length, 1);
    });

    test('fromSnapshot handles empty data', () {
      final snapshot = <String, dynamic>{};

      final page = Page.fromSnapshot(snapshot);

      expect(page.imageUrl, '');
      expect(page.sentences, isEmpty);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_app/models/sentences.dart';

void main() {
  group('Sentence', () {
    test('fromJson parses valid data', () {
      final json = {'text': 'Aw ni ce', 'audio': 'audio_url.mp3'};

      final sentence = Sentence.fromJson(json);

      expect(sentence.text, 'Aw ni ce');
      expect(sentence.audio, 'audio_url.mp3');
    });

    test('fromJson handles "tex" typo key', () {
      final json = {'tex': 'Typo text', 'audio': 'audio.mp3'};

      final sentence = Sentence.fromJson(json);

      expect(sentence.text, 'Typo text');
    });

    test('fromJson prefers "text" over "tex"', () {
      final json = {'text': 'Correct', 'tex': 'Typo', 'audio': 'audio.mp3'};

      final sentence = Sentence.fromJson(json);

      expect(sentence.text, 'Correct');
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};

      final sentence = Sentence.fromJson(json);

      expect(sentence.text, '');
      expect(sentence.audio, '');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_app/models/alphabet_model.dart';

void main() {
  group('AlphabetItem', () {
    test('fromJson parses valid data', () {
      final json = {
        'letter': 'A',
        'audio1': 'a_sound.mp3',
        'image': 'a_image.jpg',
        'audio2': 'a_word.mp3',
      };

      final item = AlphabetItem.fromJson(json);

      expect(item.letter, 'A');
      expect(item.audio1, 'a_sound.mp3');
      expect(item.image, 'a_image.jpg');
      expect(item.audio2, 'a_word.mp3');
    });
  });
}

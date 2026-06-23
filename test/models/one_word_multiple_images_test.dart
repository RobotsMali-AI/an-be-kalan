import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_app/models/onewordmultipleimagequestions.dart';

void main() {
  group('OneWordMultipleImagesQuestion', () {
    test('fromJson parses valid data', () {
      final json = {
        'question': 'Find the cat',
        'word': 'jakuma',
        'options': [
          {'image': 'cat.jpg', 'correct': true},
          {'image': 'dog.jpg', 'correct': false},
        ],
      };

      final q = OneWordMultipleImagesQuestion.fromJson(json);

      expect(q.question, 'Find the cat');
      expect(q.word, 'jakuma');
      expect(q.options.length, 2);
      expect(q.options[0].image, 'cat.jpg');
      expect(q.options[0].correct, true);
      expect(q.options[1].correct, false);
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};

      final q = OneWordMultipleImagesQuestion.fromJson(json);

      expect(q.question, '');
      expect(q.word, '');
      expect(q.options, isEmpty);
    });
  });

  group('Option', () {
    test('fromJson parses valid data', () {
      final json = {'image': 'test.jpg', 'correct': true};

      final option = Option.fromJson(json);

      expect(option.image, 'test.jpg');
      expect(option.correct, true);
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};

      final option = Option.fromJson(json);

      expect(option.image, '');
      expect(option.correct, false);
    });
  });
}

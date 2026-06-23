import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_app/models/oneimagemultiplewordsquestion.dart';

void main() {
  group('OneImageMultipleWordsQuestion', () {
    test('fromJson parses valid data', () {
      final json = {
        'question': 'What is in the image?',
        'answers': 'cat',
        'image': 'cat.jpg',
        'options': ['cat', 'dog', 'bird'],
      };

      final q = OneImageMultipleWordsQuestion.fromJson(json);

      expect(q.question, 'What is in the image?');
      expect(q.answer, 'cat');
      expect(q.image, 'cat.jpg');
      expect(q.options, ['cat', 'dog', 'bird']);
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};

      final q = OneImageMultipleWordsQuestion.fromJson(json);

      expect(q.question, '');
      expect(q.answer, '');
      expect(q.image, '');
      expect(q.options, isEmpty);
    });
  });
}

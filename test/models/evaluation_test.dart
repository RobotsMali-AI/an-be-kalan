import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_app/models/evaluation.dart' as app;

void main() {
  group('Evaluation', () {
    test('fromMap parses full evaluation data', () {
      final data = {
        'multiple': [
          {
            'questions': 'Q1?',
            'options': ['A', 'B'],
            'correct': ['A'],
          }
        ],
        'trueorfalse': [
          {'question': 'True?', 'answers': true}
        ],
        'oneimagemultiplewords': [
          {
            'question': 'What?',
            'answers': 'cat',
            'image': 'cat.jpg',
            'options': ['cat', 'dog'],
          }
        ],
        'onewordmultipleimages': [
          {
            'question': 'Find',
            'word': 'cat',
            'options': [
              {'image': 'a.jpg', 'correct': true},
              {'image': 'b.jpg', 'correct': false},
            ],
          }
        ],
      };

      final evaluation = app.Evaluation.fromMap(data);

      expect(evaluation.multiple.length, 1);
      expect(evaluation.multiple[0].question, 'Q1?');
      expect(evaluation.trueorfalse.length, 1);
      expect(evaluation.trueorfalse[0].answers, true);
      expect(evaluation.oneimagemultiplewords.length, 1);
      expect(evaluation.oneimagemultiplewords[0].answer, 'cat');
      expect(evaluation.onewordmultipleimages.length, 1);
      expect(evaluation.onewordmultipleimages[0].word, 'cat');
    });

    test('fromMap handles empty/missing lists', () {
      final data = <String, dynamic>{};

      final evaluation = app.Evaluation.fromMap(data);

      expect(evaluation.multiple, isEmpty);
      expect(evaluation.trueorfalse, isEmpty);
      expect(evaluation.oneimagemultiplewords, isEmpty);
      expect(evaluation.onewordmultipleimages, isEmpty);
    });

    test('fromMap handles partial data', () {
      final data = {
        'multiple': [
          {
            'questions': 'Only this?',
            'options': ['Yes'],
            'correct': ['Yes'],
          }
        ],
      };

      final evaluation = app.Evaluation.fromMap(data);

      expect(evaluation.multiple.length, 1);
      expect(evaluation.trueorfalse, isEmpty);
      expect(evaluation.oneimagemultiplewords, isEmpty);
      expect(evaluation.onewordmultipleimages, isEmpty);
    });
  });
}

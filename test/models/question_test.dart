import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_app/models/question.dart';

void main() {
  group('Question', () {
    test('fromMap parses valid data', () {
      final data = {
        'questions': 'What is the capital?',
        'options': ['Bamako', 'Dakar', 'Accra'],
        'correct': ['Bamako'],
      };

      final question = Question.fromMap(data);

      expect(question.question, 'What is the capital?');
      expect(question.options, ['Bamako', 'Dakar', 'Accra']);
      expect(question.correct, ['Bamako']);
    });

    test('fromMap handles null/missing fields', () {
      final data = <String, dynamic>{};

      final question = Question.fromMap(data);

      expect(question.question, '');
      expect(question.options, isEmpty);
      expect(question.correct, isEmpty);
    });

    test('toMap serializes correctly', () {
      final question = Question(
        question: 'Test?',
        options: ['A', 'B'],
        correct: ['A'],
      );

      final map = question.toMap();

      expect(map['questions'], 'Test?');
      expect(map['options'], ['A', 'B']);
      expect(map['correct'], ['A']);
    });

    test('roundtrip toMap -> fromMap preserves data', () {
      final original = Question(
        question: 'Roundtrip?',
        options: ['X', 'Y', 'Z'],
        correct: ['Y'],
      );

      final restored = Question.fromMap(original.toMap());

      expect(restored.question, original.question);
      expect(restored.options, original.options);
      expect(restored.correct, original.correct);
    });
  });
}

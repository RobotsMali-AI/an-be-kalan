import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_app/models/trueorfalse.dart';

void main() {
  group('Trueorfalse', () {
    test('fromJson parses valid data', () {
      final json = {'question': 'Mali is in Africa?', 'answers': true};

      final tof = Trueorfalse.fromJson(json);

      expect(tof.question, 'Mali is in Africa?');
      expect(tof.answers, true);
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};

      final tof = Trueorfalse.fromJson(json);

      expect(tof.question, '');
      expect(tof.answers, false);
    });

    test('fromSemb parses same as fromJson', () {
      final json = {'question': 'Test?', 'answers': false};

      final tof = Trueorfalse.fromSemb(json);

      expect(tof.question, 'Test?');
      expect(tof.answers, false);
    });

    test('toSnapshot serializes correctly', () async {
      final tof = Trueorfalse(question: 'Is this true?', answers: true);

      final snapshot = await tof.toSnapshot();

      expect(snapshot['question'], 'Is this true?');
      expect(snapshot['answers'], true);
    });
  });
}

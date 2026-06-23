import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_app/models/xpLog.dart';

void main() {
  group('XPLog', () {
    test('fromSnapshot parses valid data', () {
      final data = {
        'earnedXP': 50,
        'reason': 'Completed book',
        'date': '2025-01-15',
      };

      final log = XPLog.fromSnapshot(data);

      expect(log.earnedXP, 50);
      expect(log.reason, 'Completed book');
      expect(log.date, '2025-01-15');
    });

    test('toSnapshot serializes correctly', () {
      final log = XPLog(
        earnedXP: 100,
        reason: 'Game completed',
        date: '2025-06-01',
      );

      final snapshot = log.toSnapshot();

      expect(snapshot['earnedXP'], 100);
      expect(snapshot['reason'], 'Game completed');
      expect(snapshot['date'], '2025-06-01');
    });

    test('roundtrip preserves data', () {
      final original = XPLog(earnedXP: 25, reason: 'Reading', date: '2025-03-10');
      final restored = XPLog.fromSnapshot(original.toSnapshot());

      expect(restored.earnedXP, original.earnedXP);
      expect(restored.reason, original.reason);
      expect(restored.date, original.date);
    });
  });
}

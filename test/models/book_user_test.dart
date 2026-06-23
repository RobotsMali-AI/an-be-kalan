import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_app/models/bookUser.dart';

void main() {
  group('BookUser', () {
    group('fromSnapshot', () {
      test('parses valid data with String date', () {
        final data = {
          'title': 'Test Book',
          'bookmark': '3',
          'readingTime': 120,
          'accuracies': [0.85, 0.92, 0.78],
          'lastAccessed': '2025-01-15T10:30:00.000',
          'totalPages': 10,
          'creditedXp': 50.0,
          'creditedReadingTime': 100,
        };

        final bookUser = BookUser.fromSnapshot(data);

        expect(bookUser.title, 'Test Book');
        expect(bookUser.bookmark, '3');
        expect(bookUser.readingTime, 120);
        expect(bookUser.accuracies, [0.85, 0.92, 0.78]);
        expect(bookUser.totalPages, 10);
        expect(bookUser.creditedXp, 50.0);
        expect(bookUser.creditedReadingTime, 100);
      });

      test('handles missing creditedXp and creditedReadingTime', () {
        final data = {
          'title': 'Test Book',
          'bookmark': '0',
          'readingTime': 0,
          'accuracies': <dynamic>[],
          'lastAccessed': '2025-01-15T10:30:00.000',
          'totalPages': 5,
        };

        final bookUser = BookUser.fromSnapshot(data);

        expect(bookUser.creditedXp, 0.0);
        expect(bookUser.creditedReadingTime, 0);
      });

      test('coerces accuracy values from int to double', () {
        final data = {
          'title': 'Test',
          'bookmark': '0',
          'readingTime': 0,
          'accuracies': [1, 0, 85],
          'lastAccessed': '2025-01-01',
          'totalPages': 1,
        };

        final bookUser = BookUser.fromSnapshot(data);

        expect(bookUser.accuracies, isA<List<double>>());
      });
    });

    group('fromSemb', () {
      test('parses valid sembast data', () {
        final data = {
          'title': 'Sembast Book',
          'bookmark': '2',
          'readingTime': 60,
          'accuracies': [0.9, 0.8],
          'lastAccessed': '2025-01-15T10:30:00.000',
          'totalPages': 8,
          'creditedXp': 30.0,
          'creditedReadingTime': 50,
        };

        final bookUser = BookUser.fromSemb(data);

        expect(bookUser.title, 'Sembast Book');
        expect(bookUser.bookmark, '2');
        expect(bookUser.readingTime, 60);
        expect(bookUser.totalPages, 8);
      });
    });

    group('toSnapshot', () {
      test('serializes correctly', () {
        final bookUser = BookUser(
          title: 'Test',
          bookmark: '1',
          readingTime: 30,
          accuracies: [0.95],
          lastAccessed: DateTime(2025, 1, 15),
          totalPages: 5,
          creditedXp: 10.0,
          creditedReadingTime: 20,
        );

        final snapshot = bookUser.toSnapshot();

        expect(snapshot['title'], 'Test');
        expect(snapshot['bookmark'], '1');
        expect(snapshot['readingTime'], 30);
        expect(snapshot['accuracies'], [0.95]);
        expect(snapshot['totalPages'], 5);
        expect(snapshot['creditedXp'], 10.0);
        expect(snapshot['creditedReadingTime'], 20);
      });
    });

    group('toSemb', () {
      test('serializes lastAccessed as string', () {
        final bookUser = BookUser(
          title: 'Test',
          bookmark: '0',
          readingTime: 0,
          accuracies: [],
          lastAccessed: DateTime(2025, 6, 1),
          totalPages: 1,
        );

        final semb = bookUser.toSemb();

        expect(semb['lastAccessed'], isA<String>());
      });
    });

    group('roundtrip', () {
      test('toSnapshot -> fromSnapshot preserves data', () {
        final original = BookUser(
          title: 'Roundtrip',
          bookmark: '5',
          readingTime: 200,
          accuracies: [0.7, 0.8, 0.9],
          lastAccessed: '2025-03-10T12:00:00.000',
          totalPages: 15,
          creditedXp: 42.5,
          creditedReadingTime: 180,
        );

        final snapshot = original.toSnapshot();
        final restored = BookUser.fromSnapshot(snapshot);

        expect(restored.title, original.title);
        expect(restored.bookmark, original.bookmark);
        expect(restored.readingTime, original.readingTime);
        expect(restored.accuracies, original.accuracies);
        expect(restored.totalPages, original.totalPages);
        expect(restored.creditedXp, original.creditedXp);
      });
    });
  });
}

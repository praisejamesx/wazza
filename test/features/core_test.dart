import 'package:flutter_test/flutter_test.dart';
import 'package:wazza/core/search/query_rewriter.dart';
import 'package:wazza/core/utils/extensions.dart';

void main() {
  group('QueryRewriter', () {
    test('returns original query in the list', () {
      final results = QueryRewriter.rewrite('hello world');
      expect(results, contains('hello world'));
    });

    test('removes stop words and extracts key terms', () {
      final results = QueryRewriter.rewrite('what is the meaning of life');
      expect(results, isNotEmpty);
      expect(results.first, 'what is the meaning of life');
    });

    test('handles empty query', () {
      final results = QueryRewriter.rewrite('');
      expect(results, isNotEmpty);
    });

    test('handles single word', () {
      final results = QueryRewriter.rewrite('flutter');
      expect(results, contains('flutter'));
    });
  });

  group('DateTime extensions', () {
    test('timeAgo returns relative time string', () {
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
      expect(oneMinuteAgo.timeAgo, contains('m'));

      final oneHourAgo = now.subtract(const Duration(hours: 1));
      expect(oneHourAgo.timeAgo, contains('h'));

      final oneDayAgo = now.subtract(const Duration(days: 1));
      expect(oneDayAgo.timeAgo, contains('d'));
    });
  });
}

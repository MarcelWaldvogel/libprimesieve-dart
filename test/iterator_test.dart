import 'package:libprimesieve/prime_sequence.dart';
import 'package:libprimesieve/libprimesieve.dart';
import 'package:test/test.dart';

void main() {
  group('Sequences within [1, 1000]', () {
    PrimeSequence ps;

    setUp(() {
      numThreads = 1;
      ps = PrimeSequence(start: 1, stop_hint: 1000);
    });
    tearDown(() {
      ps.freeNativeMemory();
      ps = null;
    });

    test('First prime', () {
      expect(ps.moveNext(), equals(true));
      expect(ps.current, equals(2));
    });
    test('Two primes', () {
      expect(ps.moveNext(), equals(true));
      expect(ps.current, equals(2));
      expect(ps.moveNext(), equals(true));
      expect(ps.current, equals(3));
    });
  });
}

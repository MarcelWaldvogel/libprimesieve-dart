import 'package:libprimesieve/libprimesieve.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

final execPath = path.join('bin', 'print_primes.dart');

void iotest(List<String> args, String expectStdout) async {
  test('Printing primes with ' + ([execPath] + args).toString(), () async {
    var dartProcess = await Process.run('dart', [execPath] + args);
    expect(dartProcess.exitCode, equals(0));

    expect(dartProcess.stderr, isEmpty);
    expect(dartProcess.stdout, equals(expectStdout));
  });
}

void main() async {
  group('Primes', () {
    test('Primes in [1, 10]', () {
      expect(generatePrimes(1, 10), equals([2, 3, 5, 7]));
    });
    test('10 Primes from 100', () {
      expect(generateNPrimes(10, 100),
          equals([101, 103, 107, 109, 113, 127, 131, 137, 139, 149]));
    });
    test('First prime after 1E9', () {
      expect(nthPrime(1, 1000000000), equals(1000000007));
    });
    test('The prime after 1E9', () {
      expect(nthPrime(0, 1000000000), equals(1000000007));
    });
    test('First prime before 1E9', () {
      expect(nthPrime(-1, 1000000000), equals(999999937));
    });
    test('First prime after 1E9+7 (a prime)', () {
      expect(nthPrime(1, 1000000007), equals(1000000009));
    });
    test('The prime at 1E9+7', () {
      expect(nthPrime(0, 1000000007), equals(1000000007));
    });
    test('First prime before 1E9+7', () {
      expect(nthPrime(-1, 1000000007), equals(999999937));
    });
  });

  group('Big primes (64 bit tests)', () {
    // Not going beyond 2^53 for Javascript
    // Not using 1<<33 etc. for Javascript
    // See https://api.dart.dev/stable/2.7.1/dart-core/int-class.html
    test('First prime before 1E10', () {
      expect(nthPrime(-1, 10000000000), equals(9999999967));
    });
    test('First prime before 1E11', () {
      expect(nthPrime(-1, 100000000000), equals(99999999977));
    });
    test('First prime after 1E12', () {
      expect(nthPrime(1, 100000000000), equals(100000000003));
    });
    test('First prime after 1E15', () {
      expect(nthPrime(1, 100000000000000), equals(100000000000031));
    });
    test('Primes in [1E15, 1E15+100]', () {
      expect(
          generatePrimes(100000000000000, 100000000000100),
          equals([
            100000000000031,
            100000000000067,
            100000000000097,
            100000000000099
          ]));
    });
    test('3 primes starting at 1E15', () {
      expect(generateNPrimes(3, 100000000000000),
          equals([100000000000031, 100000000000067, 100000000000097]));
    });
  });

  group('Counting primes', () {
    test('Count primes in [1, 10]', () {
      expect(countPrimes(1, 10), equals(4));
    });
    test('Count prime twins in [10, 100]', () {
      expect(countTwins(10, 100), equals(6));
    });
    test('Count triplets in [100, 1000]', () {
      expect(countTriplets(100, 1000), equals(21));
    });
    test('Count quadruplets in [1000, 10000]', () {
      expect(countQuadruplets(1000, 10000), equals(7));
    });
    test('Count quintuplets in [10000, 100000]', () {
      expect(countQuintuplets(10000, 100000), equals(12));
    });
    test('Count sextuplets in [100000, 1000000]', () {
      expect(countSextuplets(100000, 1000000), equals(0));
    });
    test('Count sextuplets in [1000000, 10000000]', () {
      expect(countSextuplets(1000000, 10000000), equals(13));
    });
    test('Count sextuplets in [1, 1000000]', () {
      expect(countSextuplets(1, 1000000), equals(5));
    });
    test('Count sextuplets in [1, 10000000]', () {
      expect(countSextuplets(1, 10000000), equals(5 + 13));
    });
  });

  group('Printing primes using example/print_primes.dart', () {
    iotest(['10'], '2\n3\n5\n7\n');
    iotest(['-2', '10'], '(3, 5)\n(5, 7)\n');
    iotest(['-3', '44', '77'], '(67, 71, 73)\n');
    iotest(['-4', '44', '99'], '');
    iotest(['-4', '144', '199'], '(191, 193, 197, 199)\n');
    iotest(['-5', '1000000', '1010000'],
        '(1008851, 1008853, 1008857, 1008859, 1008863)\n');
    iotest(['-6', '2', '100'], '(7, 11, 13, 17, 19, 23)\n');
    iotest(['-16', '7', '23'],
        '7\n11\n13\n\17\n19\n23\n(7, 11, 13, 17, 19, 23)\n');
  });

  group('System configuration', () {
    test('Number of threads', () {
      int n = numThreads;
      expect(n, greaterThan(0));
      expect(n, lessThan(1000));
    });
    test('Modifying numThreads', () {
      int n = numThreads;
      if (n > 1) {
        numThreads = n - 1;
        expect(numThreads, equals(n - 1));
      }
      numThreads = n;
      expect(numThreads, equals(n));
    });
    test('Bounding numThreads', () {
      inhibitWarnings = true; // Do not clobber output with these expected warnings
      int n = numThreads;
      numThreads = 0;
      expect(numThreads, equals(1));
      numThreads = 1000;
      expect(numThreads, equals(n));
      inhibitWarnings = false;
    });
    test('Sieve (wheel) size', () {
      int s = sieveSize;
      expect(s, greaterThanOrEqualTo(7));
      expect(s, lessThan(4096));
    });
    test('Modifying sieveSize', () {
      int s = sieveSize;
      sieveSize = 8;
      expect(sieveSize, equals(8));
      sieveSize = 4096;
      expect(sieveSize, equals(4096));
      sieveSize = s;
      expect(sieveSize, equals(s));
    });
    test('Odd sieveSize', () {
      inhibitWarnings = true;
      int s = sieveSize;
      sieveSize = 15;
      expect(sieveSize, equals(8));
      sieveSize = 3999;
      expect(sieveSize, equals(2048));
      sieveSize = s;
      expect(sieveSize, equals(s));
      inhibitWarnings = false;
    }, tags: ['undocumented', 'unreliable']);
    test('Bounding sieveSize', () {
      inhibitWarnings = true;
      int s = sieveSize;
      sieveSize = 7;
      expect(sieveSize, equals(8));
      sieveSize = 4097;
      expect(sieveSize, equals(4096));
      sieveSize = s;
      expect(sieveSize, equals(s));
      inhibitWarnings = false;
    });
  });

  group('Whether thread count and wheel/cache size affect performance', () {
    test('Reducing number of threads', () {
      int n = numThreads;
      if (n > 1) {
        // Warm up cache
        countPrimes(1, 1000000000);

        // With all cores
        Stopwatch full = Stopwatch()..start();
        countPrimes(1, 1000000000);
        full.stop();

        // With a single core
        numThreads = 1;
        Stopwatch weak = Stopwatch()..start();
        countPrimes(1, 1000000000);
        weak.stop();

        numThreads = n;
        expect(full.elapsed, lessThan(weak.elapsed),
            reason: "$n cores should be faster than 1 core.");
      }
    });

    test('Increasing cache requirements', () {
      int s = sieveSize;
      // Warm up cache
      countPrimes(1, 1000000000);

      // With default cache
      Stopwatch full = Stopwatch()..start();
      countPrimes(1, 1000000000);
      full.stop();

      // With too much cache
      sieveSize = 4096;
      Stopwatch weak = Stopwatch()..start();
      countPrimes(1, 1000000000);
      weak.stop();

      sieveSize = s; // Reset before exception
      expect(full.elapsed, lessThan(weak.elapsed),
          reason: "$s kiB cache should be faster than 4096 kiB.");
    });
  }, tags: ['performance', 'unreliable']);
}

// Note that for public APIs directly mapping to library functions,
// minimal Dart functions are created to wrap the `ffi` function.
// This might slightly slow down operation; however, without this workaround,
// API docs created by `dartdoc` would not be helpful.

import 'dart:ffi';
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';

enum _types {
  SHORT_PRIMES,
  USHORT_PRIMES,
  INT_PRIMES,
  UINT_PRIMES,
  LONG_PRIMES,
  ULONG_PRIMES,
  LONGLONG_PRIMES,
  ULONGLONG_PRIMES,
  INT16_PRIMES,
  UINT16_PRIMES,
  INT32_PRIMES,
  UINT32_PRIMES,
  INT64_PRIMES,
  UINT64_PRIMES
}

// void *primesieve_generate_primes(uint64_t start, uint64_t stop, size_t *size, int type)
typedef _generatePrimesFunc = Pointer<Uint64> Function(
    Uint64 start, Uint64 stop, Pointer<Uint64> size, Uint32 type);
typedef _generatePrimesDart = Pointer<Uint64> Function(
    int start, int stop, Pointer<Uint64> size, int type);

// void *primesieve_generate_n_primes(uint64_t n, uint64_t start, int type)
typedef _generateNPrimesFunc = Pointer<Uint64> Function(
    Uint64 n, Uint64 start, Uint32 type);
typedef _generateNPrimesDart = Pointer<Uint64> Function(
    int n, int start, int type);

// uint64_t primesieve_nth_prime(int64_t n, uint64_t start)
typedef _nthPrimeFunc = Uint64 Function(Uint64 n, Uint64 start);
typedef _nthPrimeDart = int Function(int n, int start);

// uint64_t primesieve_count_primes(uint64_t start, uint64_t stop)
// and friends
typedef _countPrimesFunc = Uint64 Function(Uint64 start, Uint64 stop);
typedef _countPrimesDart = int Function(int start, int stop);

// void primesieve_print_primes(uint64_t start, uint64_t stop)
// and friends
typedef _printPrimesFunc = Void Function(Uint64 start, Uint64 stop);
typedef _printPrimesDart = void Function(int start, int stop);

// void primesieve_free(void *primes)
typedef _freeFunc = Void Function(Pointer<Uint64> primes);
typedef _freeDart = void Function(Pointer<Uint64> primes);

// Generic int getter/setter functions
typedef _getInt64Func = Int64 Function();
typedef _getIntFunc = Int32 Function();
typedef _getIntDart = int Function();
typedef _setIntFunc = Void Function(Int32);
typedef _setIntDart = void Function(int);

typedef _stringFunc = Pointer<Utf8> Function();

final _dylib = _findDL('primesieve');
final _uint64_primes = _types.UINT64_PRIMES.index;

DynamicLibrary _findDL(String basename) {
  final names = _shlibNames(basename);
  for (var name in names) {
    try {
      return DynamicLibrary.open(name);
    } on ArgumentError {}
  }
  throw ArgumentError(
      "Native $basename library not found; searched for $names");
}

List<String> _shlibNames(String basename) {
  if (Platform.isMacOS) return ['lib$basename.dylib'];
  if (Platform.isWindows) return ['$basename.dll'];
  return ['lib$basename.so.9', 'lib$basename.so'];
}

final _free = _dylib
    .lookup<NativeFunction<_freeFunc>>('primesieve_free')
    .asFunction<_freeDart>();
List<int> _uint64arrToIntArr(Pointer<Uint64> arr, int count) {
  // Copy to Dart array
  var primeList = List<int>(count);
  for (var i = 0; i < count; i++) {
    primeList[i] = arr.elementAt(i).value;
  }
  _free(arr);
  return primeList;
}

/// Return an array with all the primes in [[start], [stop]].
///
/// Unless changed with [numThreads], all CPU cores are used.
List<int> generatePrimes(int start, int stop) {
  Pointer<Uint64> sizePointer = allocate();
  final primes = _generatePrimes(start, stop, sizePointer, _uint64_primes);
  final size = sizePointer.value;
  free(sizePointer);
  return _uint64arrToIntArr(primes, size);
}

final _generatePrimes = _dylib
    .lookup<NativeFunction<_generatePrimesFunc>>('primesieve_generate_primes')
    .asFunction<_generatePrimesDart>();

/// Return an array with the first [n] primes >= [start].
///
/// Unless changed with [numThreads], all CPU cores are used.
List<int> generateNPrimes(int n, int start) {
  final primes = _generateNPrimes(n, start, _uint64_primes);
  return _uint64arrToIntArr(primes, n);
}

final _generateNPrimes = _dylib
    .lookup<NativeFunction<_generateNPrimesFunc>>(
        'primesieve_generate_n_primes')
    .asFunction<_generateNPrimesDart>();

/// Find the [n]th prime beyond [start].
///
/// Unless changed with [numThreads], all CPU cores are used.
///
/// Each call to [nthPrime()] incurs an initialization overhead of
/// O(sqrt([start])) even if [n] is tiny. Hence, it is not a good idea to use
/// [nthPrime()] repeatedly in a loop to get the next (or previous) prime.
///
/// For positive/negative [n], the [n]th prime after/before [start] will be
/// returned. For [n] = 0, [start] will be returned, if it is prime, otherwise,
/// the next prime will be returned (i.e., the same prime which [n] = 1 would).
int nthPrime(int n, int start) => _nthPrime(n, start);
final _nthPrime = _dylib
    .lookup<NativeFunction<_nthPrimeFunc>>('primesieve_nth_prime')
    .asFunction<_nthPrimeDart>();

/// Count the primes within the interval [[start], [stop]].
///
/// Unless changed with [numThreads], all CPU cores are used.
///
/// Note that each call to [countPrimes()] incurs an initialization overhead
/// of O(sqrt([stop])) even if the interval [[start], [stop]] is tiny.
int countPrimes(int start, int stop) => _countPrimes(start, stop);
final _countPrimes = _dylib
    .lookup<NativeFunction<_countPrimesFunc>>('primesieve_count_primes')
    .asFunction<_countPrimesDart>();

/// Count the prime twins within the interval [[start], [stop]].
///
/// See [countPrimes()] for more information.
int countTwins(int start, int stop) => _countTwins(start, stop);
final _countTwins = _dylib
    .lookup<NativeFunction<_countPrimesFunc>>('primesieve_count_twins')
    .asFunction<_countPrimesDart>();

/// Count the prime triplets within the interval [[start], [stop]].
///
/// See [countPrimes()] for more information.
int countTriplets(int start, int stop) => _countTriplets(start, stop);
final _countTriplets = _dylib
    .lookup<NativeFunction<_countPrimesFunc>>('primesieve_count_triplets')
    .asFunction<_countPrimesDart>();

/// Count the prime quadruplets within the interval [[start], [stop]].
///
/// See [countPrimes()] for more information.
int countQuadruplets(int start, int stop) => _countQuadruplets(start, stop);
final _countQuadruplets = _dylib
    .lookup<NativeFunction<_countPrimesFunc>>('primesieve_count_quadruplets')
    .asFunction<_countPrimesDart>();

/// Count the prime quintuplets within the interval [[start], [stop]].
///
/// See [countPrimes()] for more information.
int countQuintuplets(int start, int stop) => _countQuintuplets(start, stop);
final _countQuintuplets = _dylib
    .lookup<NativeFunction<_countPrimesFunc>>('primesieve_count_quintuplets')
    .asFunction<_countPrimesDart>();

/// Count the prime sextuplets within the interval [[start], [stop]].
///
/// See [countPrimes()] for more information.
int countSextuplets(int start, int stop) => _countSextuplets(start, stop);
final _countSextuplets = _dylib
    .lookup<NativeFunction<_countPrimesFunc>>('primesieve_count_sextuplets')
    .asFunction<_countPrimesDart>();

/// Print the primes within the interval [[start], [stop]].
///
/// See [printPrimes()] for more information.
void printPrimes(int start, int stop) {
  _printPrimes(start, stop);
}

final _printPrimes = _dylib
    .lookup<NativeFunction<_printPrimesFunc>>('primesieve_print_primes')
    .asFunction<_printPrimesDart>();

/// Print the prime twins within the interval [[start], [stop]].
///
/// See [printPrimes()] for more information.
void printTwins(int start, int stop) {
  _printTwins(start, stop);
}

final _printTwins = _dylib
    .lookup<NativeFunction<_printPrimesFunc>>('primesieve_print_twins')
    .asFunction<_printPrimesDart>();

/// Print the prime triplets within the interval [[start], [stop]].
///
/// See [printPrimes()] for more information.
void printTriplets(int start, int stop) {
  _printTriplets(start, stop);
}

final _printTriplets = _dylib
    .lookup<NativeFunction<_printPrimesFunc>>('primesieve_print_triplets')
    .asFunction<_printPrimesDart>();

/// Print the prime quadruplets within the interval [[start], [stop]].
///
/// See [printPrimes()] for more information.
void printQuadruplets(int start, int stop) {
  _printQuadruplets(start, stop);
}

final _printQuadruplets = _dylib
    .lookup<NativeFunction<_printPrimesFunc>>('primesieve_print_quadruplets')
    .asFunction<_printPrimesDart>();

/// Print the prime quintuplets within the interval [[start], [stop]].
///
/// See [printPrimes()] for more information.
void printQuintuplets(int start, int stop) {
  _printQuintuplets(start, stop);
}

final _printQuintuplets = _dylib
    .lookup<NativeFunction<_printPrimesFunc>>('primesieve_print_quintuplets')
    .asFunction<_printPrimesDart>();

/// Print the prime sextuplets within the interval [[start], [stop]].
///
/// See [printPrimes()] for more information.
void printSextuplets(int start, int stop) {
  _printSextuplets(start, stop);
}

final _printSextuplets = _dylib
    .lookup<NativeFunction<_printPrimesFunc>>('primesieve_print_sextuplets')
    .asFunction<_printPrimesDart>();

/// The largest valid `stop` number for primesieve.
///
/// Returns 2^64-1 (`UINT64_MAX`).
int get maxStop => _maxStop();
final _maxStop = _dylib
    .lookup<NativeFunction<_getInt64Func>>('primesieve_get_max_stop')
    .asFunction<_getIntDart>();

/// The sieve size in KiB ([kibibyte](https://en.wikipedia.org/wiki/Kibibyte)).
///
/// Achieve the best sieving performance with a sieve size of your CPU's
/// L1 or L2 cache size (per core).
///
/// [sieveSize] must be at least 8 (8 kiB), at most 4096 (4 MiB).
/// Apparently, the library rounds down sizes to the next power of two.
///
/// When trying to set this to a value modified by the library,
/// a warning will be printed, unless disabled with [inhibitWarnings].
///
/// Like [numThreads], this can be used to tune the performance. However,
/// the default should be reasonable for most settings.
int get sieveSize => _getSieveSize();
set sieveSize(int kiBSize) {
  _setSieveSize(kiBSize);
  if (sieveSize != kiBSize && !inhibitWarnings) {
    print("primesieve.dart: Warning: sieveSize $kiBSize adapted to $sieveSize");
  }
}

final _setSieveSize = _dylib
    .lookup<NativeFunction<_setIntFunc>>('primesieve_set_sieve_size')
    .asFunction<_setIntDart>();
final _getSieveSize = _dylib
    .lookup<NativeFunction<_getIntFunc>>('primesieve_get_sieve_size')
    .asFunction<_getIntDart>();

/// The number of threads to use in all the functions that generate or enumerate
/// primes.
///
/// This defaults to the number of cores and is bounded in [1, number of cores].
/// When trying to set outside this bound, a warning will be printed,
/// unless disabled with [inhibitWarnings].
///
/// Like [sieveSize], this can be used to tune the performance. However,
/// the default should be reasonable for most settings.
int get numThreads => _getNumThreads();
set numThreads(int count) {
  _setNumThreads(count);
  if (numThreads != count && !inhibitWarnings) {
    print("primesieve.dart: Warning: numThreads $count bounded by $numThreads");
  }
}

final _setNumThreads = _dylib
    .lookup<NativeFunction<_setIntFunc>>('primesieve_set_num_threads')
    .asFunction<_setIntDart>();
final _getNumThreads = _dylib
    .lookup<NativeFunction<_getIntFunc>>('primesieve_get_num_threads')
    .asFunction<_getIntDart>();

/// The C/C++ primesieve library version number, in the form “minor.major”.
String get version => Utf8.fromUtf8(_version());
final _version = _dylib
    .lookup<NativeFunction<_stringFunc>>('primesieve_version')
    .asFunction<_stringFunc>();

/// The Dart interface version number, in the form "minor.major".
final dartLibraryVersion = "0.1";

/// Whether to inhibit warnings generated when assigning [numThreads] or
/// [sieveSize] with a value which is modified by the underlying library.
bool inhibitWarnings = false;

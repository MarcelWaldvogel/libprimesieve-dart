import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:libprimesieve/libprimesieve.dart';

class _PrimeIteratorState extends Struct {
  @Uint64()
  int i;

  @Uint64()
  int last_idx;

  @Uint64()
  int start;

  @Uint64()
  int stop;

  @Uint64()
  int stop_hint;

  @Uint64()
  int dist;

  Pointer<Uint64> primes;

  Pointer vector;

  Pointer primeGenerator;

  @Uint32()
  int is_error;

  factory _PrimeIteratorState.allocate() => allocate<_PrimeIteratorState>().ref;
}

typedef _iteratorOnlyFunc = Void Function(Pointer<_PrimeIteratorState> it);
typedef _iteratorOnlyDart = void Function(Pointer<_PrimeIteratorState> it);
typedef _iteratorSkipToFunc = Void Function(
    Pointer<_PrimeIteratorState> it, Uint64 start, Uint64 stop_hint);
typedef _iteratorSkipToDart = void Function(
    Pointer<_PrimeIteratorState> it, int start, int stop_hint);

final _init = dylib
    .lookup<NativeFunction<_iteratorOnlyFunc>>('primesieve_init')
    .asFunction<_iteratorOnlyDart>();
final _free = dylib
    .lookup<NativeFunction<_iteratorOnlyFunc>>('primesieve_free')
    .asFunction<_iteratorOnlyDart>();
final _nextPrimes = dylib
    .lookup<NativeFunction<_iteratorOnlyFunc>>('primesieve_generate_next_primes')
    .asFunction<_iteratorOnlyDart>();
final _prevPrimes = dylib
    .lookup<NativeFunction<_iteratorOnlyFunc>>('primesieve_generate_prev_primes')
    .asFunction<_iteratorOnlyDart>();
final _skipTo = dylib
    .lookup<NativeFunction<_iteratorSkipToFunc>>('primesieve_skipto')
    .asFunction<_iteratorSkipToDart>();

class PrimeSequence implements BidirectionalIterator<int> {
  var _value;
  final Pointer<_PrimeIteratorState> it = _allocInit();

  static Pointer<_PrimeIteratorState> _allocInit() {
    Pointer<_PrimeIteratorState> it = allocate();
    _init(it);
    return it;
  }

  void freeNativeMemory() {
    _free(it);
    free(it);
  }

  PrimeSequence({int start: 1, int stop_hint}) {
    // The default value of an optional parameter must be constant; workaround:
    if (stop_hint == null) stop_hint = maxStop;
    _skipTo(it, start, stop_hint);
  }

  bool skipTo(int start, {int stop_hint}) {
    if (stop_hint == null) stop_hint = maxStop;
    _skipTo(it, start, stop_hint);
  }

  bool movePrevious() {
    // primesieve_prev_prime() is an inline function, emulating it.
    // ```C
    // if (it->i-- == 0)
    //   primesieve_generate_prev_primes(it);
    // return it->primes[it->i];
    // ```
    if (it.ref.i-- == 0) {
      _prevPrimes(it);
    }
    _value = it.ref.primes[it.ref.i];
    return (_value != 0);
  }

  bool moveNext() {
    // primesieve_next_prime() is an inline function, emulating it.
    // ```C
    // if (it->i++ == it->last_idx)
    //   primesieve_generate_next_primes(it);
    // return it->primes[it->i];
    // ```
    if (it.ref.i++ == it.ref.last_idx) {
      print("NextPrimes");
      _nextPrimes(it);
    }
    _value = it.ref.primes[it.ref.i];
    return (_value != maxStop);
  }

  get current => _value;
}

# `libprimesieve` for Dart

This is a wrapper for [Kim Walisch's `primesieve` C/C++
library](https://github.com/kimwalisch/primesieve).
It requires the library to already be installed.
That library is only available for some platforms, please check
availability.

If you have the underlying native library installed, you can
add this library as `libprimesieve` to your Dart package.

## Looking for a simpler/pure Dart alternative?

If you only need primes up to about 1E9 or prefer to have a Dart-only
implementation, you may want to try
[Prime-Sieve-Dart](https://github.com/MarcelWaldvogel/Prime-Sieve-Dart)
instead, which can be installed with `pub` as `prime-sieve` (note the
dash).

Please note that the pure Dart alternative is significantly slower and
lacks many features.

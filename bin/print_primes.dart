import 'package:libprimesieve/libprimesieve.dart';
import 'package:args/args.dart';
import 'dart:io';

var parser;
void usage() {
  print("""Usage: dart print_primes.dart [options] [<start>] <stop>
    Print primes (or twins, …, sextuplets) in [start, stop].
    Start defaults to 1.

""" +
      parser.usage);
  exit(1);
}
void main(List<String> args) async {
  parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addFlag('primes',
        abbr: '1', negatable: false,
        help: "Print primes (default if no other option is given)")
    ..addFlag('twins',
        abbr: '2', negatable: false,
        help: "Print prime twins")
    ..addFlag('triplets',
        abbr: '3', negatable: false,
        help: "Print prime triplets")
    ..addFlag('quadruplets',
        abbr: '4', negatable: false,
        help: "Print prime quadruplets")
    ..addFlag('quintuplets',
        abbr: '5', negatable: false,
        help: "Print prime quintuplets")
    ..addFlag('sextuplets',
        abbr: '6', negatable: false,
        help: "Print prime sextuplets");
  var results = parser.parse(args);

  if (results['help']) usage();
  if (results.rest.length < 1) usage();
  if (results.rest.length > 2) usage();
  int start, stop;
  if (results.rest.length == 1) {
    start = 1;
    stop = int.tryParse(results.rest[0]);
  } else {
    start = int.tryParse(results.rest[0]);
    stop = int.tryParse(results.rest[1]);
  }
  if (start == null || stop == null) usage();

  // No option or explicit `--primes`?
  if (!(results['twins'] || results['triplets'] || results['quadruplets']
      || results['quintuplets'] || results['sextuplets'])
      || results['primes']) {
    printPrimes(start, stop);
  }
  if (results['twins']) printTwins(start, stop);
  if (results['triplets']) printTriplets(start, stop);
  if (results['quadruplets']) printQuadruplets(start, stop);
  if (results['quintuplets']) printQuintuplets(start, stop);
  if (results['sextuplets']) printSextuplets(start, stop);
}

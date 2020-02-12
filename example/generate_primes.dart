import 'package:libprimesieve/libprimesieve.dart';

void main() {
  print("* The primes between 1 and 10 are:");
  printPrimes(1, 10);

  print("* The first prime after 100 is ${nthPrime(1, 100)}");
  print("* The last prime before 1000 is ${nthPrime(-1, 1000)}");
  print("* The first 5 primes after 100000 are ${generateNPrimes(5, 100000)}");

  print("* The prime sextuplets between 1000000000 and 1010000000 are:");
  printSextuplets(1000000000, 1010000000);

  print("* There are ${countPrimes(1, 10)} primes between 1 and 10");
  print("* There are ${countPrimes(1, 10000000000)} primes between 1 and 10000000000");
}

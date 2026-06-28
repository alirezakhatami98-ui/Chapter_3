import 'dart:io';
import 'dart:math';

class NegativeNumberException implements Exception {
  final String message;
  NegativeNumberException(this.message);

  @override
  String toString() => 'NegativeNumberException: $message';
}

double calculateSquareRoot(double number) {
  if (number < 0) {
    throw NegativeNumberException('Number cannot be negative.');
  } else {
    return sqrt(number);
  }
}

void main() {
  stdout.write('Input a number: ');
  String? numStr = stdin.readLineSync();

  try {
    double num = double.parse(numStr ?? '');
    double result = calculateSquareRoot(num);
    print('Square root of number $num is $result');
  } on NegativeNumberException catch (e) {
    print('Negative error: $e');
  } on FormatException catch (e) {
    print('Converting error: $e');
  } finally {
    print('End of operation');
  }
}

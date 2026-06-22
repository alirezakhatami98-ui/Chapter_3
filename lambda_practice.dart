void main() {
  List<int> numbers = [3, 17, 9, 42, 6, 31, 8];
  var bigNumbers = numbers.where((number) => number > 10);
  print(bigNumbers.toList());

  var printEvenOdd = (List<int> numbers) {
    return numbers.map((n) => n % 2 == 0 ? '$n is even' : '$n is odd');
  };
  printEvenOdd(numbers).forEach(print);
}

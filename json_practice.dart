import 'dart:io';
import 'dart:convert';

class Book {
  final String title;
  final String author;
  final int year;

  Book({required this.title, required this.author, required this.year});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] as String,
      author: json['author'] as String,
      year: json['year'] as int,
    );
  }
}

Book? findBookByAuthor(List<Book> books, String author) {
  for (var book in books) {
    if (book.author == author) {
      return book;
    }
  }
  print('Book by $author not found.');
  return null;
}

Future<void> main() async {
  final file = File('${Directory.current.path}/books.json');
  Map<String, dynamic> jsonMap = jsonDecode(await file.readAsString());
  List<Book> books = (jsonMap['books'] as List)
      .map((json) => Book.fromJson(json))
      .toList();
  books.forEach(
    (book) => print('${book.title} by ${book.author} (${book.year})'),
  );
  while (true) {
    stdout.write('Which author are you looking for? ');
    String author = stdin.readLineSync() ?? '';
    if (author == '') {
      print('Please enter a valid author name.');
      continue;
    } else {
      final searchBook = findBookByAuthor(books, author);
      if (searchBook != null) {
        print(
          'Found: ${searchBook.title} by ${searchBook.author} (${searchBook.year})',
        );
      }
      break;
    }
  }
}

import 'dart:io';
import 'dart:convert';

class Book {
  final String title;
  final String author;
  final int year;
  final String genre;

  Book({
    required this.title,
    required this.author,
    required this.year,
    required this.genre,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('title') ||
        !json.containsKey('author') ||
        !json.containsKey('year') ||
        !json.containsKey('genre')) {
      throw FormatException('Missing required fields in book JSON.');
    }

    if (json['title'] is! String ||
        json['author'] is! String ||
        json['year'] is! int ||
        json['genre'] is! String) {
      throw FormatException(
        "Book JSON is missing required fields or has invalid types.",
      );
    }
    return Book(
      title: json['title'] as String,
      author: json['author'] as String,
      year: json['year'] as int,
      genre: json['genre'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'author': author,
    'year': year,
    'genre': genre,
  };

  @override
  String toString() =>
      'Title: $title, Author: $author, Year: $year, Genre: $genre';
}

class BookManager {
  List<Book> books = [];

  Future<void> loadBooksFromFile(String filePath) async {
    File file = File(filePath);
    if (!await file.exists()) {
      throw FileException('The file does not exist.');
    }
    Map<String, dynamic> jsonMap;
    try {
      jsonMap = jsonDecode(await file.readAsString());
    } on FormatException {
      throw FormatException('The books.json file is corrupted.');
    }
    if (jsonMap['books'] is! List<dynamic>) {
      throw FormatException("Invalid format: 'books' must be a list.");
    }
    books = (jsonMap['books'] as List<dynamic>)
        .map((json) => Book.fromJson(json))
        .toList();
  }

  List<Book> getAllBooks() {
    return books;
  }

  List<Book> searchByTitle(String query) {
    final lowerQuery = query.toLowerCase();
    return books
        .where((book) => book.title.toLowerCase().contains(lowerQuery))
        .toList();
  }

  List<Book> filterByGenre(String genre) {
    final lowerGenre = genre.toLowerCase();
    return books
        .where((book) => book.genre.toLowerCase() == lowerGenre)
        .toList();
  }

  List<Book> filterByAuthor(String author) {
    final lowerAuthor = author.toLowerCase();
    return books
        .where((book) => book.author.toLowerCase().contains(lowerAuthor))
        .toList();
  }
}

class FileException implements Exception {
  String message;
  FileException(this.message);

  @override
  String toString() => 'FileException: $message';
}

int getMenuNumber() {
  int? optNum;
  do {
    stdout.write('Enter the desired option number: ');
    String? optNumStr = stdin.readLineSync();
    optNum = int.tryParse(optNumStr ?? '');

    if (optNum == null || optNum < 1 || optNum > 5) {
      print('Please input valid integer number between 1 & 5.');
    }
  } while (optNum == null || optNum < 1 || optNum > 5);
  return optNum;
}

String getNonEmptyInput() {
  while (true) {
    stdout.write("Enter input: ");
    String? input = stdin.readLineSync();

    if (input != null && input.isNotEmpty) {
      return input;
    }
    print('Invalid input!');
  }
}

void showResults(List<Book> result) {
  if (result.isEmpty) {
    print('No book found!');
  } else {
    result.forEach(print);
  }
}

Future<void> main() async {
  BookManager bookManager = BookManager();
  String filePath = '${Directory.current.path}/books.json';
  try {
    await bookManager.loadBooksFromFile(filePath);
  } on FileException catch (e) {
    print(e);
    return;
  } on FormatException catch (e) {
    print(e);
    return;
  }
  int optNum;

  do {
    print(
      '\n1. Show all books\n2. Search by title\n3. Filter by genre\n4. Filter by author\n5. Exit',
    );
    optNum = getMenuNumber();

    switch (optNum) {
      case 1:
        final result = bookManager.getAllBooks();
        showResults(result);
        break;

      case 2:
        final title = getNonEmptyInput();
        final result = bookManager.searchByTitle(title);
        showResults(result);
        break;

      case 3:
        final genre = getNonEmptyInput();
        final result = bookManager.filterByGenre(genre);
        showResults(result);
        break;

      case 4:
        final author = getNonEmptyInput();
        final result = bookManager.filterByAuthor(author);
        showResults(result);
        break;

      case 5:
        print('Exiting...');
        break;
    }
  } while (optNum != 5);
}

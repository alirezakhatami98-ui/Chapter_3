class Book {
  String title, author;
  late String summary;

  Book({required this.title, required this.author});

  void loadSummary() {
    summary = 'This is a summary of the book "$title" by $author.';
  }
}

void main() {
  Book book = Book(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald');
  book.loadSummary();
  print(book.summary);
}

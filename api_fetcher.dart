import 'dart:io';
import 'dart:convert';

class Post {
  String title, body;
  int id, userId;

  Post({
    required this.title,
    required this.body,
    required this.id,
    required this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title'] as String,
      body: json['body'] as String,
      id: json['id'] as int,
      userId: json['userId'] as int,
    );
  }
}

Future<List<dynamic>> fetchJsonList(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('خطای سرور: ${response.statusCode}');
    }
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body) as List<dynamic>;
  } finally {
    client.close();
  }
}

Future<void> main() async {
  const url = 'https://jsonplaceholder.typicode.com/posts';
  try {
    List<dynamic> jsonList = await fetchJsonList(url);
    List<Post> posts = jsonList.map((json) => Post.fromJson(json)).toList();
    int count = posts.length;
    print('Fetched $count posts from the API.');
    while (true) {
      stdout.write('How many posts would you like to see? ');
      String input = stdin.readLineSync() ?? '';
      int? numberOfPosts = int.tryParse(input);
      if (numberOfPosts != null &&
          numberOfPosts > 0 &&
          numberOfPosts <= count) {
        posts = posts.take(numberOfPosts).toList();
        break;
      } else {
        print('Please enter a valid number.');
      }
    }
    // Using Stringbuffer and padding to format the output as a Table. limit length of body with substring
    final buffer = StringBuffer();
    buffer.writeln(
      '| ${'ID'.padRight(5)} | ${'User ID'.padRight(10)} | ${'Title'.padRight(30)} | ${'Body'.padRight(50)} |',
    );
    buffer.writeln('| ${'-' * 5} | ${'-' * 10} | ${'-' * 30} | ${'-' * 50} |');
    for (var post in posts) {
      buffer.writeln(
        '| ${post.id.toString().padRight(5)} | ${post.userId.toString().padRight(10)} | ${post.title.length > 30 ? '${post.title.substring(0, 27)}...' : post.title.padRight(30)} | ${post.body.length > 50 ? '${post.body.substring(0, 47)}...' : post.body.padRight(50)} |',
      );
    }
    print(buffer.toString());
  } catch (e) {
    print('Error fetching posts: $e');
  }
}

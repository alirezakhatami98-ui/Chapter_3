import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  final file = File('${Directory.current.path}/log.txt');
  if (!await file.exists()) {
    print('File does not exist');
    return;
  }

  final stream = file
      .openRead()
      .transform(utf8.decoder) // تبدیل بایت‌ها به رشته
      .transform(LineSplitter()); // تقسیم بر اساس خط

  int lineNumber = 0;
  await for (final line in stream) {
    lineNumber++;
    print('Line $lineNumber: $line');
  }
  print('total number of lines: $lineNumber');
}

import 'dart:io';

Future<void> main() async {
  final dir = Directory('${Directory.current.path}/backup');
  if (!await dir.exists()) {
    await dir.create();
    print('Directory created at ${dir.path}');
  }

  final file = File('${dir.path}/log.txt');
  if (!await file.exists()) {
    await file.create();
    print('File created at ${file.path}');
  }

  await file.writeAsString(DateTime.now().toString(), mode: FileMode.append);

  String content = await file.readAsString();
  print('File content: $content');
}

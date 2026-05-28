import 'dart:io';

Future<String?> readFileAsString(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  return file.readAsString();
}

Future<void> writeFileAsString(String path, String content) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(content, flush: true);
}

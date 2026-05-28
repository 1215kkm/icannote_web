// Web stub for native file I/O.
//
// On web there is no filesystem path access — the file_picker package
// surfaces file contents as bytes instead. These functions must therefore
// never be reached on web; they exist only to satisfy the conditional
// import in `file_service.dart`.

Future<String?> readFileAsString(String path) {
  throw UnsupportedError(
      'Path-based file I/O is not available on web. Use file_picker bytes.');
}

Future<void> writeFileAsString(String path, String content) {
  throw UnsupportedError(
      'Path-based file I/O is not available on web. Use file_picker saveFile.');
}

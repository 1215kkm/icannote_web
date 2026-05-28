// Native (Windows/macOS/Linux) implementation of downloadBytes — shows
// a "Save As" dialog and writes the bytes to the chosen path.

import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

Future<bool> downloadBytes({
  required String fileName,
  required Uint8List bytes,
  String mimeType = 'application/octet-stream',
}) async {
  // file_picker.saveFile on desktop returns the chosen path; it does NOT
  // write the bytes for us. The caller must do the write — that's what we
  // do here. (Passing bytes is harmless on platforms that ignore it.)
  final ext = fileName.contains('.')
      ? fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase()
      : null;
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save',
    fileName: fileName,
    type: ext != null ? FileType.custom : FileType.any,
    allowedExtensions: ext != null ? [ext] : null,
  );
  if (path == null) return false;
  await File(path).writeAsBytes(bytes, flush: true);
  return true;
}

// Web implementation of downloadBytes — uses an anchor + Blob URL to
// trigger a browser download. file_picker's saveFile() throws
// UnimplementedError on web (as of file_picker 8.x), so we cannot rely
// on it for save flows.
//
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
//   dart:html is the simplest cross-version way to trigger a browser
//   download without taking on the package:web + dart:js_interop
//   migration. Migrate when we touch this code again.

import 'dart:html' as html;
import 'dart:typed_data';

Future<bool> downloadBytes({
  required String fileName,
  required Uint8List bytes,
  String mimeType = 'application/octet-stream',
}) async {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  try {
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
  } finally {
    html.Url.revokeObjectUrl(url);
  }
  return true;
}

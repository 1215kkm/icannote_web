// Cross-platform "save bytes to a file the user picks" helper.
//
// Use this for every flow that needs to hand a file to the user
// (.icn save, PDF export, PNG export). file_picker's `saveFile()` is
// not implemented on web in current versions, so this helper bridges to
// a Blob-anchor download there and to a real file write on native.

export 'file_download_web.dart'
    if (dart.library.io) 'file_download_native.dart';

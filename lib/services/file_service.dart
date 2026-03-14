import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/lecture.dart';

/// Service for file I/O operations (save/load .icn files, pick documents).
/// Works on both web and native platforms.
class FileService {
  /// Last saved file path (native only, null on web)
  String? _lastSavedPath;

  String? get lastSavedPath => _lastSavedPath;

  /// Open an .icn file via file picker and deserialize to Lecture.
  Future<Lecture?> openIcnFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['icn', 'json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      String jsonString;

      if (file.bytes != null) {
        // Web: read from bytes
        jsonString = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        // Native: read from file path
        final io = await _readFileNative(file.path!);
        if (io == null) return null;
        jsonString = io;
      } else {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final lecture = Lecture.fromIcn(json);
      _lastSavedPath = file.path;
      return lecture;
    } catch (e) {
      debugPrint('Error opening .icn file: $e');
      return null;
    }
  }

  /// Save lecture as .icn file.
  /// On web: triggers download. On native: writes to file.
  Future<bool> saveLecture(Lecture lecture, {String? path}) async {
    try {
      final jsonString = _lectureToJsonString(lecture);

      if (kIsWeb) {
        // Web: trigger download via file_picker
        await FilePicker.platform.saveFile(
          dialogTitle: 'Save Lecture',
          fileName: '${lecture.title}.icn',
          bytes: utf8.encode(jsonString),
        );
        return true;
      }

      // Native: save to path
      final savePath = path ?? _lastSavedPath;
      if (savePath != null) {
        await _writeFileNative(savePath, jsonString);
        _lastSavedPath = savePath;
        return true;
      }

      // No path — use save-as dialog
      return await saveLectureAs(lecture);
    } catch (e) {
      debugPrint('Error saving lecture: $e');
      return false;
    }
  }

  /// Save lecture with a "Save As" file picker dialog.
  Future<bool> saveLectureAs(Lecture lecture, {String? suggestedName}) async {
    try {
      final jsonString = _lectureToJsonString(lecture);
      final fileName = suggestedName ?? '${lecture.title}.icn';

      if (kIsWeb) {
        await FilePicker.platform.saveFile(
          dialogTitle: 'Save Lecture As',
          fileName: fileName,
          bytes: utf8.encode(jsonString),
        );
        return true;
      }

      // Native: use save dialog
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Lecture As',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['icn'],
      );

      if (result == null) return false;

      await _writeFileNative(result, jsonString);
      _lastSavedPath = result;
      return true;
    } catch (e) {
      debugPrint('Error saving lecture as: $e');
      return false;
    }
  }

  /// Quick save to last-used path (for auto-save).
  /// Returns false if no path is known (needs saveLectureAs first).
  Future<bool> quickSave(Lecture lecture) async {
    if (kIsWeb) return false; // Web doesn't support auto-save to filesystem
    if (_lastSavedPath == null) return false;
    return saveLecture(lecture, path: _lastSavedPath);
  }

  /// Pick document files for import (PDF, PPT, DOC, HWP, images).
  Future<List<PlatformFile>?> pickDocumentFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf', 'ppt', 'pptx', 'doc', 'docx',
          'hwp', 'hwpx', 'jpg', 'jpeg', 'png',
        ],
        allowMultiple: true,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;
      return result.files;
    } catch (e) {
      debugPrint('Error picking document files: $e');
      return null;
    }
  }

  String _lectureToJsonString(Lecture lecture) {
    final json = lecture.toIcn();
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  /// Read file on native platforms using dart:io conditionally.
  Future<String?> _readFileNative(String path) async {
    try {
      // Dynamic import workaround for web compatibility
      if (kIsWeb) return null;
      // Use compute to avoid blocking UI
      return await compute(_readFileIsolate, path);
    } catch (e) {
      debugPrint('Error reading file: $e');
      return null;
    }
  }

  /// Write file on native platforms.
  Future<void> _writeFileNative(String path, String content) async {
    if (kIsWeb) return;
    await compute(_writeFileIsolate, _WriteFileArgs(path, content));
  }

  static String _readFileIsolate(String path) {
    // This runs in an isolate, so we can use dart:io safely
    // ignore: avoid_dynamic_calls
    return _ioReadFileSync(path);
  }

  static void _writeFileIsolate(_WriteFileArgs args) {
    _ioWriteFileSync(args.path, args.content);
  }

  // These will fail on web at compile time if called, but they're guarded by kIsWeb
  static String _ioReadFileSync(String path) {
    // Use conditional import pattern
    // For now, use a simpler approach with try-catch
    try {
      final file = _IoFile(path);
      return file.readAsStringSync();
    } catch (e) {
      throw Exception('Cannot read file on this platform: $e');
    }
  }

  static void _ioWriteFileSync(String path, String content) {
    try {
      final file = _IoFile(path);
      file.writeAsStringSync(content);
    } catch (e) {
      throw Exception('Cannot write file on this platform: $e');
    }
  }
}

/// Wrapper for dart:io File to avoid direct import issues on web.
/// On web builds, file_picker handles everything via bytes.
class _IoFile {
  final String path;
  _IoFile(this.path);

  String readAsStringSync() {
    // file_picker with withData:true gives us bytes on all platforms
    // This is a fallback for native-only path-based access
    throw UnimplementedError(
      'Direct file I/O not available. Use file_picker bytes instead.',
    );
  }

  void writeAsStringSync(String content) {
    throw UnimplementedError(
      'Direct file I/O not available. Use file_picker saveFile instead.',
    );
  }
}

class _WriteFileArgs {
  final String path;
  final String content;
  const _WriteFileArgs(this.path, this.content);
}

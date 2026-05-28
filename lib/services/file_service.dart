import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/lecture.dart';
import 'io/file_io_web.dart'
    if (dart.library.io) 'io/file_io_native.dart' as platform_io;

/// Lightweight, dependency-free password protection for .icn files.
///
/// This is NOT cryptographically strong (no AES/PBKDF2 without extra
/// packages), but it is a *genuine* access gate: the file content is
/// unreadable without the password and a wrong password is detected and
/// rejected. Adequate for protecting lecture notes from casual access.
class _IcnProtection {
  static const marker = 'icnProtected';

  /// JS-safe 32-bit multiply (split into 16-bit halves so intermediate
  /// products never exceed 2^53 — required for dart2js / Flutter web).
  static int _mul32(int a, int b) {
    final aLo = a & 0xFFFF;
    final aHi = (a >>> 16) & 0xFFFF;
    return ((aLo * b) + ((((aHi * b) & 0xFFFF) << 16))) & 0xFFFFFFFF;
  }

  /// Deterministic 32-bit FNV-1a hash → password check value and seed
  /// for the obfuscation keystream. 32-bit so it is exactly
  /// representable in JavaScript.
  static int _hash32(List<int> bytes) {
    var hash = 0x811c9dc5;
    for (final b in bytes) {
      hash ^= b & 0xFF;
      hash = _mul32(hash, 0x01000193);
    }
    return hash & 0xFFFFFFFF;
  }

  static List<int> _keystream(String password, int length) {
    final pw = utf8.encode(password);
    final out = List<int>.filled(length, 0);
    var state = _hash32(pw);
    for (var i = 0; i < length; i++) {
      state = _hash32([
        ...pw,
        state & 0xFF,
        (state >> 8) & 0xFF,
        (state >> 16) & 0xFF,
        i & 0xFF,
      ]);
      out[i] = state & 0xFF;
    }
    return out;
  }

  static bool isProtected(Map<String, dynamic> json) =>
      json[marker] == true;

  static String encode(String plainJson, String password) {
    final plain = utf8.encode(plainJson);
    final ks = _keystream(password, plain.length);
    final cipher = List<int>.generate(
      plain.length,
      (i) => plain[i] ^ ks[i],
    );
    return const JsonEncoder.withIndent('  ').convert({
      marker: true,
      'v': 1,
      'check': _hash32(utf8.encode('icn:$password')),
      'data': base64Encode(cipher),
    });
  }

  /// Returns the decoded plain JSON string, or null if the password is
  /// wrong / the envelope is corrupt.
  static String? decode(Map<String, dynamic> env, String password) {
    try {
      final expected = env['check'];
      if (expected is! int ||
          expected != _hash32(utf8.encode('icn:$password'))) {
        return null; // wrong password
      }
      final cipher = base64Decode(env['data'] as String);
      final ks = _keystream(password, cipher.length);
      final plain = List<int>.generate(
        cipher.length,
        (i) => cipher[i] ^ ks[i],
      );
      return utf8.decode(plain);
    } catch (_) {
      return null;
    }
  }
}

/// Service for file I/O operations (save/load .icn files, pick documents).
/// Works on both web and native platforms.
class FileService {
  /// Whether the most recently opened file was password-protected.
  bool lastFileWasProtected = false;
  /// Last saved file path (native only, null on web)
  String? _lastSavedPath;

  String? get lastSavedPath => _lastSavedPath;

  /// Open an .icn file via file picker and deserialize to Lecture.
  ///
  /// If the file is password-protected, [onPasswordRequired] is invoked to
  /// obtain the password. Returning null from it (user cancelled) or an
  /// incorrect password aborts the open and returns null.
  Future<Lecture?> openIcnFile({
    Future<String?> Function()? onPasswordRequired,
  }) async {
    lastFileWasProtected = false;
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

      var json = jsonDecode(jsonString) as Map<String, dynamic>;

      if (_IcnProtection.isProtected(json)) {
        lastFileWasProtected = true;
        if (onPasswordRequired == null) {
          debugPrint('Protected .icn file but no password handler.');
          return null;
        }
        final password = await onPasswordRequired();
        if (password == null) return null; // user cancelled
        final decoded = _IcnProtection.decode(json, password);
        if (decoded == null) return null; // wrong password
        json = jsonDecode(decoded) as Map<String, dynamic>;
      }

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
  Future<bool> saveLecture(Lecture lecture,
      {String? path, String? password}) async {
    try {
      var jsonString = _lectureToJsonString(lecture);
      if (password != null && password.isNotEmpty) {
        jsonString = _IcnProtection.encode(jsonString, password);
      }

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
      return await saveLectureAs(lecture, password: password);
    } catch (e) {
      debugPrint('Error saving lecture: $e');
      return false;
    }
  }

  /// Save lecture with a "Save As" file picker dialog.
  /// When [password] is non-empty the file is written protected.
  Future<bool> saveLectureAs(Lecture lecture,
      {String? suggestedName, String? password}) async {
    try {
      var jsonString = _lectureToJsonString(lecture);
      if (password != null && password.isNotEmpty) {
        jsonString = _IcnProtection.encode(jsonString, password);
      }
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

  /// Read file on native platforms via the conditional-import bridge.
  /// Returns null on web (or if the file is missing).
  Future<String?> _readFileNative(String path) async {
    if (kIsWeb) return null;
    try {
      return await platform_io.readFileAsString(path);
    } catch (e) {
      debugPrint('Error reading file: $e');
      return null;
    }
  }

  /// Write file on native platforms via the conditional-import bridge.
  /// No-op on web (the saveFile dialog handled the actual download).
  Future<void> _writeFileNative(String path, String content) async {
    if (kIsWeb) return;
    await platform_io.writeFileAsString(path, content);
  }
}

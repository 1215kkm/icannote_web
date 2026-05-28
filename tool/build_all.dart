// Convenience build runner for ICanNote.
//
// Builds every release target supported on the *current* OS:
//   * Web (everywhere)
//   * Windows (when run on Windows)
//   * macOS  (when run on macOS)
//
// Usage:  dart run tool/build_all.dart
//
// Optional flags:
//   --no-web        skip the web build
//   --no-desktop    skip the desktop build for the current OS

import 'dart:io';

Future<void> main(List<String> args) async {
  final skipWeb = args.contains('--no-web');
  final skipDesktop = args.contains('--no-desktop');

  if (!skipWeb) {
    await _run('flutter', ['build', 'web', '--release'], label: 'web');
  }

  if (!skipDesktop) {
    if (Platform.isWindows) {
      await _run('flutter', ['build', 'windows', '--release'],
          label: 'windows');
    } else if (Platform.isMacOS) {
      await _run('flutter', ['build', 'macos', '--release'], label: 'macos');
    } else {
      stdout.writeln(
          '[build_all] Desktop build skipped — no desktop target for ${Platform.operatingSystem}.');
    }
  }

  stdout.writeln('[build_all] Done.');
}

Future<void> _run(String exe, List<String> args, {required String label}) async {
  stdout.writeln('[build_all] === $label ===');
  final proc =
      await Process.start(exe, args, mode: ProcessStartMode.inheritStdio,
          runInShell: Platform.isWindows);
  final code = await proc.exitCode;
  if (code != 0) {
    stderr.writeln('[build_all] $label build failed (exit $code).');
    exit(code);
  }
}

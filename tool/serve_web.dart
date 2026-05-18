// Minimal static file server for the built Flutter web app (build/web).
// Usage: dart run tool/serve_web.dart [port]
import 'dart:io';

const _types = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript',
  '.mjs': 'application/javascript',
  '.json': 'application/json',
  '.wasm': 'application/wasm',
  '.css': 'text/css',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args.first) ?? 8091 : 8091;
  final root = Directory('build/web');
  if (!root.existsSync()) {
    stderr.writeln('build/web not found. Run: flutter build web');
    exit(1);
  }

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('ICanNote web serving at http://127.0.0.1:$port');

  await for (final req in server) {
    try {
      var path = req.uri.path;
      if (path == '/' || path.isEmpty) path = '/index.html';
      var file = File('${root.path}$path');
      // SPA fallback: unknown route -> index.html
      if (!file.existsSync()) file = File('${root.path}/index.html');

      final ext = file.path.contains('.')
          ? file.path.substring(file.path.lastIndexOf('.'))
          : '';
      req.response.headers
          .set('Content-Type', _types[ext] ?? 'application/octet-stream');
      req.response.headers.set('Cache-Control', 'no-cache');
      await req.response.addStream(file.openRead());
      await req.response.close();
    } catch (_) {
      try {
        req.response.statusCode = HttpStatus.internalServerError;
        await req.response.close();
      } catch (_) {}
    }
  }
}

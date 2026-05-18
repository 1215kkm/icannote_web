// Headless-Chrome verification driver using the DevTools Protocol over a
// raw WebSocket (dart:io only — no extra packages).
//
// Usage: dart run tool/cdp_verify.dart <appUrl> <outDir>
// Requires Chrome already running with --remote-debugging-port=9222.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

const cdpHost = '127.0.0.1:9222';

late WebSocket ws;
int _id = 0;
final Map<int, Completer<Map<String, dynamic>>> _pending = {};
final List<String> consoleErrors = [];
final List<String> exceptions = [];
String? _sessionId;

Future<Map<String, dynamic>> send(String method,
    [Map<String, dynamic>? params, bool useSession = true]) {
  final id = ++_id;
  final msg = <String, dynamic>{'id': id, 'method': method};
  if (params != null) msg['params'] = params;
  if (useSession && _sessionId != null) msg['sessionId'] = _sessionId;
  final c = Completer<Map<String, dynamic>>();
  _pending[id] = c;
  ws.add(jsonEncode(msg));
  return c.future.timeout(const Duration(seconds: 30),
      onTimeout: () => {'error': 'timeout: $method'});
}

void _onMessage(dynamic raw) {
  final m = jsonDecode(raw as String) as Map<String, dynamic>;
  if (m.containsKey('id') && _pending.containsKey(m['id'])) {
    _pending.remove(m['id'])!.complete(m['result'] as Map<String, dynamic>? ??
        {'error': m['error']});
    return;
  }
  final method = m['method'] as String?;
  final p = m['params'] as Map<String, dynamic>? ?? {};
  if (method == 'Runtime.exceptionThrown') {
    final d = p['exceptionDetails'] as Map<String, dynamic>? ?? {};
    final ex = d['exception'] as Map<String, dynamic>?;
    exceptions.add(ex?['description'] ?? d['text'] ?? d.toString());
  } else if (method == 'Runtime.consoleAPICalled') {
    if (p['type'] == 'error') {
      final args = (p['args'] as List?) ?? [];
      consoleErrors.add(args
          .map((a) => (a as Map)['value'] ?? a['description'] ?? '')
          .join(' '));
    }
  } else if (method == 'Log.entryAdded') {
    final e = p['entry'] as Map<String, dynamic>? ?? {};
    if (e['level'] == 'error') {
      consoleErrors.add('[${e['source']}] ${e['text']}');
    }
  }
}

Future<void> screenshot(String path) async {
  final r = await send('Page.captureScreenshot', {'format': 'png'});
  final data = r['data'] as String?;
  if (data != null) {
    File(path).writeAsBytesSync(base64Decode(data));
    stdout.writeln('SHOT $path');
  } else {
    stdout.writeln('SHOT FAILED: $r');
  }
}

Future<void> mouse(String type, num x, num y,
    {String button = 'left', int clickCount = 1}) async {
  await send('Input.dispatchMouseEvent', {
    'type': type,
    'x': x,
    'y': y,
    'button': button,
    'buttons': type == 'mouseMoved' ? 1 : (button == 'left' ? 1 : 0),
    'clickCount': clickCount,
  });
}

Future<void> click(num x, num y) async {
  await mouse('mousePressed', x, y);
  await Future.delayed(const Duration(milliseconds: 60));
  await mouse('mouseReleased', x, y);
  await Future.delayed(const Duration(milliseconds: 400));
}

Future<void> drawStroke(List<List<num>> pts) async {
  await mouse('mousePressed', pts.first[0], pts.first[1]);
  for (final pt in pts.skip(1)) {
    await mouse('mouseMoved', pt[0], pt[1]);
    await Future.delayed(const Duration(milliseconds: 20));
  }
  await mouse('mouseReleased', pts.last[0], pts.last[1]);
  await Future.delayed(const Duration(milliseconds: 300));
}

Future<void> key(String keyName, int keyCode,
    {bool ctrl = false}) async {
  final mods = ctrl ? 2 : 0;
  await send('Input.dispatchKeyEvent', {
    'type': 'keyDown',
    'modifiers': mods,
    'key': keyName,
    'windowsVirtualKeyCode': keyCode,
  });
  await send('Input.dispatchKeyEvent', {
    'type': 'keyUp',
    'modifiers': mods,
    'key': keyName,
    'windowsVirtualKeyCode': keyCode,
  });
  await Future.delayed(const Duration(milliseconds: 400));
}

Future<String> evalJs(String expr) async {
  final r = await send('Runtime.evaluate', {
    'expression': expr,
    'returnByValue': true,
    'awaitPromise': true,
  });
  final res = r['result'] as Map<String, dynamic>?;
  return res?['value']?.toString() ?? r.toString();
}

Future<void> main(List<String> args) async {
  final url = args.isNotEmpty ? args[0] : 'http://127.0.0.1:8091/';
  final out = args.length > 1 ? args[1] : 'tool/_verify';
  Directory(out).createSync(recursive: true);

  final ver = jsonDecode(
      await _httpGet('http://$cdpHost/json/version')) as Map<String, dynamic>;
  ws = await WebSocket.connect(ver['webSocketDebuggerUrl'] as String);
  ws.listen(_onMessage);

  // New tab
  final t = await send('Target.createTarget', {'url': 'about:blank'}, false);
  final targetId = t['targetId'];
  final a = await send('Target.attachToTarget',
      {'targetId': targetId, 'flatten': true}, false);
  _sessionId = a['sessionId'] as String;

  await send('Page.enable', {});
  await send('Runtime.enable', {});
  await send('Log.enable', {});
  await send('Runtime.runIfWaitingForDebugger', {});

  stdout.writeln('NAV $url');
  await send('Page.navigate', {'url': url});
  // Flutter web bootstrap needs time (load main.dart.js + engine init).
  await Future.delayed(const Duration(seconds: 12));
  await screenshot('$out/01_home.png');

  // Report DOM signal that Flutter rendered something.
  final hasView = await evalJs(
      "(document.querySelector('flutter-view')||document.querySelector('flt-glass-pane')||document.querySelector('canvas'))?'yes':'no'");
  stdout.writeln('FLUTTER_VIEW=$hasView');

  // --- Run the scripted scenario (coords are filled in after we see 01) ---
  final scenario = args.length > 2 ? args[2] : '';
  if (scenario.isNotEmpty) {
    for (final step in scenario.split(';')) {
      final parts = step.split(':');
      final cmd = parts[0];
      try {
        if (cmd == 'click') {
          await click(num.parse(parts[1]), num.parse(parts[2]));
        } else if (cmd == 'shot') {
          await screenshot('$out/${parts[1]}');
        } else if (cmd == 'draw') {
          final pts = parts[1]
              .split('~')
              .map((p) => p.split(',').map(num.parse).toList())
              .toList();
          await drawStroke(pts);
        } else if (cmd == 'ctrlz') {
          await key('z', 90, ctrl: true);
        } else if (cmd == 'wait') {
          await Future.delayed(Duration(milliseconds: int.parse(parts[1])));
        }
      } catch (e) {
        stdout.writeln('STEP ERROR $step -> $e');
      }
    }
  }

  stdout.writeln('--- CONSOLE ERRORS (${consoleErrors.length}) ---');
  for (final e in consoleErrors.take(40)) {
    stdout.writeln(e);
  }
  stdout.writeln('--- EXCEPTIONS (${exceptions.length}) ---');
  for (final e in exceptions.take(40)) {
    stdout.writeln(e);
  }
  stdout.writeln('DONE');
  await ws.close();
  exit(0);
}

Future<String> _httpGet(String u) async {
  final c = HttpClient();
  final req = await c.getUrl(Uri.parse(u));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  c.close();
  return body;
}

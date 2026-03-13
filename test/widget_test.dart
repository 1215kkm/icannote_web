import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icannote/app.dart';

void main() {
  testWidgets('App launches with home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ICanNoteApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('New Lecture'), findsOneWidget);
    expect(find.text('Lecture File'), findsOneWidget);
    expect(find.text('Open Textbook'), findsOneWidget);
  });
}

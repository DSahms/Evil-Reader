import 'package:flutter_test/flutter_test.dart';
import 'package:evil_reader/main.dart';

void main() {
  testWidgets('Ledger smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EvilReaderApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('THE READER: INTERVIEWS WITH EVIL'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:novacalc/main.dart';

void main() {
  testWidgets('NovaCalc app renders', (tester) async {
    await tester.pumpWidget(const NovaCalcApp());
    await tester.pump();
    expect(find.text('NovaCalc'), findsOneWidget);
  });
}

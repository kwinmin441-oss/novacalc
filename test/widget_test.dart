
import 'package:flutter_test/flutter_test.dart';
import 'package:novacalc/main.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = null;
  });

  testWidgets('NovaCalc app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const NovaCalcApp());

    expect(find.byType(NovaCalcApp), findsOneWidget);
  });
}

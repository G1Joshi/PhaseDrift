import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phasedrift/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Menu & Title Navigation Harness', () {
    testWidgets('boots to TitleScreen and navigates to ChamberSelectScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PhaseDriftApp());
      await tester.pump();

      expect(find.text('PHASEDRIFT'), findsOneWidget);
      expect(find.text('CHAMBER MATRIX'), findsOneWidget);

      await tester.tap(find.text('CHAMBER MATRIX'));
      await tester.pumpAndSettle();

      expect(find.textContaining('SECTOR DIRECTORY'), findsWidgets);
      expect(find.text('SECTOR 01'), findsOneWidget);

      // Tap into Sector 1 to open its chambers
      await tester.tap(find.text('SOLAR DAWN'));
      await tester.pumpAndSettle();

      expect(find.text('CHAMBER 01'), findsOneWidget);
      expect(find.text('AWAKENING'), findsOneWidget);

      // Tap back to return to Sector Directory
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.textContaining('SECTOR DIRECTORY'), findsWidgets);
    });

    testWidgets('navigates from TitleScreen to SettingsScreen and back', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PhaseDriftApp());
      await tester.pump();

      await tester.tap(find.text('SYSTEM SETTINGS'));
      await tester.pumpAndSettle();

      expect(find.text('SYSTEM SETTINGS'), findsOneWidget);
      expect(find.text('AUDIO TELEMETRY'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('ENTER THE DRIFT'), findsOneWidget);
    });
  });
}

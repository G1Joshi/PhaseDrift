import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phasedrift/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PhaseDrift app boots to title screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('PHASEDRIFT'), findsOneWidget);
    expect(find.text('ENTER THE DRIFT'), findsOneWidget);
    expect(find.text('CHAMBER MATRIX'), findsOneWidget);
  });
}

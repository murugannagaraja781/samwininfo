import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:real_estate_app/components/common/bottom_nav_bar.dart';
import 'package:real_estate_app/data/local/local_storage_service.dart';
import 'package:real_estate_app/main.dart';
import 'package:real_estate_app/state/app_state_providers.dart';

void main() {
  testWidgets('RealEstateApp boots and renders marketplace with bilingual support', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
        ],
        child: const RealEstateApp(),
      ),
    );

    // Verify navigation bar and bottom navigation items render in Tamil by default
    expect(find.byType(BottomNavBar), findsOneWidget);
    expect(find.text('முகப்பு'), findsWidgets);
    expect(find.text('சாட்'), findsWidgets);
    expect(find.text('என் விளம்பரங்கள்'), findsWidgets);

    // Verify categories render in Tamil
    expect(find.textContaining('நிலம்'), findsWidgets);
    expect(find.textContaining('தோட்டம்'), findsWidgets);
    expect(find.textContaining('கடை'), findsWidgets);
    expect(find.textContaining('அபார்ட்மெண்ட்'), findsWidgets);
    expect(find.textContaining('வாடகைக்கு'), findsWidgets);

    // Verify Front Quick Tools render prominently
    expect(find.text('மக்களின் தேவை'), findsWidgets);
    expect(find.text('நில அளவை மாற்றி'), findsWidgets);
  });
}

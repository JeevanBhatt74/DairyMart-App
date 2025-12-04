import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// FIX 1: Use lowercase 'dairymart' to match the package name in pubspec.yaml
import 'package:dairymart/main.dart';
import 'package:dairymart/screens/splash/splash_screen.dart'; 
// FIX 2: Import OnboardingScreen because that is the actual destination now
import 'package:dairymart/screens/onboarding/onboarding_screen.dart'; 

void main() {
  testWidgets('App starts, displays Splash, and navigates to Onboarding', (WidgetTester tester) async {
    
    // 1. Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // 2. Verification Step 1: Check that the SplashScreen is visible immediately.
    expect(find.byType(SplashScreen), findsOneWidget, 
        reason: 'The application should start with the SplashScreen visible.');

    // Verify the presence of the CircularProgressIndicator (loading spinner).
    expect(find.byType(CircularProgressIndicator), findsOneWidget, 
        reason: 'The SplashScreen should contain a loading indicator.');

    // 3. Advance the clock. 
    // We use pumpAndSettle to wait for the 3.5s timer AND the animations to finish.
    // We wait 4 seconds to be safe.
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // 4. Verification Step 2: Check that the app has navigated successfully.
    
    // The SplashScreen should now be gone.
    expect(find.byType(SplashScreen), findsNothing, 
        reason: 'After the timer delay, the SplashScreen should no longer be in the widget tree.');
    
    // FIX 3: The app navigates to OnboardingScreen first, not LoginScreen.
    expect(find.byType(OnboardingScreen), findsOneWidget,
        reason: 'After the splash delay, the app should navigate to the OnboardingScreen.');
        
    // Optional: Check for text specific to the first Onboarding page to be sure
    expect(find.text('Fresh from Farm'), findsOneWidget,
        reason: 'The first Onboarding screen title should be visible.');
  });
}
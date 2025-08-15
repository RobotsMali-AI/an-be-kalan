import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:literacy_app/auth.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/backend_code/asr_service.dart';
import 'package:literacy_app/backend_code/semb_database.dart';
import 'package:literacy_app/backend_code/user_session_service.dart';
import 'package:literacy_app/confidialiter.dart';
import 'package:literacy_app/firebase_options.dart';
import 'package:literacy_app/home.dart';
import 'package:literacy_app/onboarding_screens.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/simple_locale.dart';

/// Requires that a Firebase local emulator is running locally.
/// See https://firebase.flutter.dev/docs/auth/start/#optional-prototype-and-test-with-firebase-local-emulator-suite
bool shouldUseFirebaseEmulator = false;

late final FirebaseApp app;

// Requires that the Firebase Auth emulator is running locally
// e.g via melos run firebase:emulator.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? hasSeenConfidialiter = prefs.getBool('hasSeenConfidialiter');
  bool? hasSeenOnboarding = prefs.getBool('hasSeenOnboarding');
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Load locale before runApp
  final simpleLocale = SimpleLocale();
  await simpleLocale.load();
  // Initialize ASR service
  try {
    final success = await ASRService.instance.initialize();
    if (!success) {
      print(
          'Warning: ASR service initialization failed, fallback to API will be used');
    }
  } catch (e) {
    print('Error initializing ASR service: $e');
  }
  await FirebaseAppCheck.instance.activate(
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.playIntegrity,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
  );

//const LiteracyAppEntry()
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserSessionService()),
      ChangeNotifierProvider(create: (_) => ApiFirebaseService()),
      ChangeNotifierProvider(create: (_) => DatabaseHelper()),
      ChangeNotifierProvider<SimpleLocale>.value(value: simpleLocale),
    ],
    child: LiteracyAppEntry(
      hasSeenConfidialiter: hasSeenConfidialiter,
      hasSeenOnboarding: hasSeenOnboarding,
    ),
  ));
  //runApp();
}

/// The entry point of the application.
///
/// Returns a [MaterialApp].
class LiteracyAppEntry extends StatefulWidget {
  const LiteracyAppEntry({
    Key? key,
    required this.hasSeenConfidialiter,
    required this.hasSeenOnboarding,
  }) : super(key: key);
  final bool? hasSeenConfidialiter;
  final bool? hasSeenOnboarding;

  @override
  State<LiteracyAppEntry> createState() => _LiteracyAppEntryState();
}

class _LiteracyAppEntryState extends State<LiteracyAppEntry> {
  @override
  void dispose() {
    // Clean up ASR service when app is disposed
    ASRService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'An be Kalan',
      theme: ThemeData(primarySwatch: Colors.purple, useMaterial3: true),
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Visibility(
                  visible: constraints.maxWidth >= 1200,
                  child: Expanded(
                    child: Container(
                      height: double.infinity,
                      color: Theme.of(context).colorScheme.primary,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'An be Kalan Desktop',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth >= 1200
                      ? constraints.maxWidth / 2
                      : constraints.maxWidth,
                  child: Consumer<UserSessionService>(
                    builder: (context, userSession, _) {
                      // Use a more stable approach that doesn't rebuild on every change
                      if (userSession.currentUser == null) {
                        // Only initialize once, don't rebuild
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            userSession.initializeSession();
                          }
                        });
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      // Always check onboarding flow first, regardless of user session
                      if (widget.hasSeenConfidialiter != true) {
                        return const PrivacyPolicyPage();
                      }

                      if (widget.hasSeenOnboarding != true) {
                        return const OnboardingScreens();
                      }

                      // After onboarding is complete, check user session
                      return const HomePage();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Debug function to test ASR status - call this from anywhere
Future<void> debugASRStatus() async {
  print('\n=== ASR DEBUG STATUS ===');
  final status = ASRService.instance.getStatus();

  status.forEach((key, value) {
    print('$key: $value');
  });

  print('========================\n');

  // Test with a sample if you want
  // You can uncomment this when you have a test audio file
  /*
  const testAudioPath = '/path/to/test/audio.wav';
  final file = File(testAudioPath);
  if (await file.exists()) {
    print('Testing transcription with sample audio...');
    final result = await ASRService.instance.transcribeAudio(testAudioPath);
    print('Test result: $result');
  }
  */
}

// Function to force local model usage (disable API fallback)
void forceLocalModelOnly() {
  ASRService.instance.setAllowAPIFallback(false);
  print('ASR forced to use local model only - API fallback disabled');
}

// Function to re-enable API fallback
void enableAPIFallback() {
  ASRService.instance.setAllowAPIFallback(true);
  print('ASR API fallback re-enabled');
}

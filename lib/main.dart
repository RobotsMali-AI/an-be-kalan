import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:literacy_app/auth.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/backend_code/semb_database.dart';
import 'package:literacy_app/backend_code/transccribe.dart';
import 'package:literacy_app/firebase_options.dart';
import 'package:literacy_app/home.dart';
import 'package:provider/provider.dart';

/// Requires that a Firebase local emulator is running locally.
/// See https://firebase.flutter.dev/docs/auth/start/#optional-prototype-and-test-with-firebase-local-emulator-suite
bool shouldUseFirebaseEmulator = false;

late final FirebaseApp app;
late final FirebaseAuth auth;

// Requires that the Firebase Auth emulator is running locally
// e.g via melos run firebase:emulator.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  auth = FirebaseAuth.instance;

  if (shouldUseFirebaseEmulator) {
    await auth.useAuthEmulator('localhost', 9099);
  }
//const LiteracyAppEntry()
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ApiFirebaseService()),
      ChangeNotifierProvider(create: (_) => DatabaseHelper())
    ],
    child: const LiteracyAppEntry(),
  ));
  //runApp();
}

/// The entry point of the application.
///
/// Returns a [MaterialApp].
class LiteracyAppEntry extends StatelessWidget {
  const LiteracyAppEntry({Key? key}) : super(key: key);
  // SpeechToText speech = SpeechToText();
  @override
  Widget build(BuildContext context) {
    // speech.processAudio();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'An be Kalan',
      theme: ThemeData(primarySwatch: Colors.purple),
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
                              'Firebase Auth Desktop',
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
                  child: StreamBuilder<User?>(
                    stream: auth.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return const HomePage();
                      }
                      return const AuthGate();
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

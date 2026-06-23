import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import 'package:literacy_app/routes.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';
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
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasSeenConfidialiter = prefs.getBool('hasSeenConfidialiter');
    bool? hasSeenOnboarding = prefs.getBool('hasSeenOnboarding');
    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Load locale before runApp
    final simpleLocale = SimpleLocale();
    await simpleLocale.load();
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );

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
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
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
  bool _modelReady = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _downloadError;

  @override
  void initState() {
    super.initState();
    _checkAndDownloadModel();
  }

  @override
  void dispose() {
    ASRService.instance.dispose();
    super.dispose();
  }

  Future<void> _checkAndDownloadModel() async {
    setState(() {
      _isDownloading = true;
      _downloadError = null;
    });

    try {
      ASRService.instance.setAllowAPIFallback(false);
      final success = await ASRService.instance.initialize(
        onDownloadProgress: (progress) {
          if (mounted) {
            setState(() => _downloadProgress = progress);
          }
        },
      );
      if (mounted) {
        if (success) {
          setState(() {
            _modelReady = true;
            _isDownloading = false;
          });
        } else {
          setState(() {
            _isDownloading = false;
            _downloadError = 'Model initialization failed';
          });
        }
      }
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack,
          reason: 'ASR model download');
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'An be Kalan',
      theme: ThemeData(primarySwatch: Colors.purple, useMaterial3: true),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: _modelReady ? _buildAppContent() : _buildDownloadScreen(),
    );
  }

  Widget _buildDownloadScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App logo/icon area
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 32),
                Text(
                  'An be Kalan',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preparing speech recognition...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                ),
                const SizedBox(height: 40),

                if (_downloadError != null) ...[
                  Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Download failed. Please check your internet connection.',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _checkAndDownloadModel,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ] else ...[
                  // Progress bar
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _downloadProgress > 0
                                  ? 'Downloading model...'
                                  : 'Initializing...',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.charcoal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_downloadProgress > 0)
                              Text(
                                '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _downloadProgress > 0
                                ? _downloadProgress
                                : null,
                            backgroundColor: AppColors.lightGrey,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryGreen),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This only happens once',
                    style: AppTextStyles.captionText.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppContent() {
    return Scaffold(
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
                    if (userSession.currentUser == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          userSession.initializeSession();
                        }
                      });
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (widget.hasSeenConfidialiter != true) {
                      return const PrivacyPolicyPage();
                    }

                    if (widget.hasSeenOnboarding != true) {
                      return const OnboardingScreens();
                    }

                    return const HomePage();
                  },
                ),
              ),
            ],
          );
        },
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

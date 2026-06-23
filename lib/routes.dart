import 'package:flutter/material.dart';
import 'package:literacy_app/auth.dart';
import 'package:literacy_app/feedback.dart';
import 'package:literacy_app/home.dart';
import 'package:literacy_app/lesson_screen.dart';
import 'package:literacy_app/models/Users.dart';

class AppRoutes {
  static const String home = '/home';
  static const String auth = '/auth';
  static const String lesson = '/lesson';
  static const String feedback = '/feedback';
  static const String wordComplete = '/games/word-complete';
  static const String correctSpell = '/games/correct-spell';
  static const String chooseContext = '/games/context';
  static const String alphabet = '/games/alphabet';
  static const String multipleChoice = '/eval/multiple-choice';
  static const String trueFalse = '/eval/true-false';
  static const String oneImageMultipleWords = '/eval/one-image-words';
  static const String oneWordMultipleImages = '/eval/one-word-images';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case auth:
        return MaterialPageRoute(
          builder: (_) => const AuthGate(),
          settings: settings,
        );
      case feedback:
        return MaterialPageRoute(
          builder: (_) => const FeedbackScreen(),
          settings: settings,
        );
      case lesson:
        final args = settings.arguments as LessonScreenArgs;
        return MaterialPageRoute(
          builder: (_) => LessonScreen(
            isOffLine: args.isOffLine,
            uid: args.uid ?? '',
            bookTitle: args.bookTitle,
            userdata: args.userData!,
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
    }
  }
}

class LessonScreenArgs {
  final bool isOffLine;
  final String? uid;
  final String bookTitle;
  final Users? userData;

  const LessonScreenArgs({
    required this.isOffLine,
    this.uid,
    required this.bookTitle,
    this.userData,
  });
}

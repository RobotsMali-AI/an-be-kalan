import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer_master/fade_shimmer_master.dart';
import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/backend_code/semb_database.dart';
import 'package:literacy_app/backend_code/user_session_service.dart';
import 'package:literacy_app/backend_code/asr_service.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:literacy_app/tutorial_service.dart';
import 'package:literacy_app/widgets/OneImageMultipleWordsPage.dart';
import 'package:literacy_app/widgets/floatingHintButton.dart';
import 'package:literacy_app/widgets/multiple_choose_question.dart';
import 'package:literacy_app/widgets/one_word_fourth_image.dart';
import 'package:audio_session/audio_session.dart';
import 'package:literacy_app/widgets/true_or_false_page.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart'
    hide AVAudioSessionCategory; // Replace just_audio with audioplayers
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'models/Users.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'theme/app_colors.dart';
import 'theme/app_styles.dart';
import 'dart:math';

class LessonScreen extends StatefulWidget {
  final String uid;
  final Users userdata;
  final String bookTitle;
  final Book? book;
  final bool isOffLine;

  const LessonScreen({
    required this.uid,
    required this.userdata,
    required this.bookTitle,
    required this.isOffLine,
    this.book,
    Key? key,
  }) : super(key: key);

  @override
  LessonScreenState createState() => LessonScreenState();
}

class LessonScreenState extends State<LessonScreen>
    with WidgetsBindingObserver {
  final Record _audioRecorder = Record();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _sentencePlayer =
      AudioPlayer(); // New player for sentence audio

  // GlobalKeys for tutorial targets
  final GlobalKey _micButtonKey = GlobalKey();
  final GlobalKey _audioButtonKey = GlobalKey();
  final GlobalKey _resetButtonKey = GlobalKey();

  bool isRecording = false;
  bool hasRecording = false;
  bool isInProgress = false;
  bool hasTranscription = false;
  bool lastPage = false;
  bool _sending = false;
  bool _loading = true;
  bool isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

  String? _filePath;
  Book? bookData;
  List<String> currentSentences = [];
  int currentPage = 0;
  int currentSentenceIndex = 0;
  String currentSentence = '';
  String currentAudio = '';
  List<TextSpan> currentTextSpans = [];
  String currentImageUrl = '';

  int readingTime = 0; // Total accumulated reading time from previous sessions
  int currentSessionTime = 0; // Time accumulated in current session
  DateTime? startTime; // Start time of current sentence/page
  DateTime? sessionStartTime; // Start time of entire lesson session

  List<double> accuracies = [];

  // ASR Debug variables
  bool _showASRDebug = false;
  Map<String, dynamic>? _asrStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Listen to app lifecycle
    setupLesson();
    setupAudioSession();
    _initializeASR();
    _loadASRStatus();

    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((PlayerState playerState) {
      if (mounted) {
        if (playerState == PlayerState.completed) {
          setState(() {
            isPlaying = false;
            _currentPosition = _audioDuration;
          });
        } else {
          setState(() {
            isPlaying = playerState == PlayerState.playing;
          });
        }
      }
    });

    _audioPlayer.onDurationChanged.listen((Duration d) {
      if (mounted) {
        setState(() {
          _audioDuration = d;
        });
      }
    });
  }

  Future<void> setupLesson() async {
    Book? response = !widget.isOffLine
        ? await context.read<ApiFirebaseService>().getBook(widget.bookTitle)
        : await context.read<DatabaseHelper>().getBook(widget.bookTitle);
    if (response != null && mounted) {
      setState(() {
        bookData = response;
        _loading = false;
      });
      setupInitialPageAndSentence();

      // Show tutorial for first-time users
      _checkAndShowTutorial();
    }
  }

  void setupInitialPageAndSentence() {
    final bookmarkedIndex = widget.userdata.inProgressBooks
        .indexWhere((book) => book.title == widget.bookTitle);

    if (bookmarkedIndex != -1) {
      isInProgress = true;
      BookUser bookProgress = widget.userdata.inProgressBooks[bookmarkedIndex];
      String bookMarkAt = bookProgress.bookmark;
      currentPage = int.parse(bookMarkAt);
      if (currentPage == bookData!.content.length - 1) {
        lastPage = true;
      }
      readingTime = bookProgress.readingTime;
      accuracies = (bookProgress.accuracies as List<dynamic>)
          .map((e) => e as double)
          .toList();
    } else {
      currentPage = 0;
    }

    String pageKey = currentPage.toString();

    if (bookData!.content.containsKey(pageKey)) {
      final audio =
          bookData!.content[pageKey]!.sentences.map((e) => e.audio).toList();
      currentAudio = audio[currentSentenceIndex];
      currentSentences = List<String>.from(
          bookData!.content[pageKey]!.sentences.map((e) => e.text)).toList();
      currentSentence = currentSentences.isNotEmpty
          ? currentSentences[currentSentenceIndex]
          : '';
      currentTextSpans = [TextSpan(text: currentSentence)];
      currentImageUrl = bookData!.content[pageKey]!.imageUrl;
      startTime = DateTime.now();
      sessionStartTime =
          DateTime.now(); // Track when the entire session started
    } else {
      currentSentences = [];
      currentSentence = '';
      currentTextSpans = [const TextSpan(text: "Page not found")];
      currentImageUrl = '';
    }
  }

  Future<void> setupAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
    ));
    await session.setActive(true);
  }

  Future<void> _initializeASR() async {
    try {
      final initialized = await ASRService.instance.initialize();
      if (initialized) {
        print('ASR service initialized successfully for lesson screen');
      } else {
        print('ASR service initialization failed, will fall back to API');
      }
      _loadASRStatus();
    } catch (e) {
      print('Error initializing ASR service: $e');
    }
  }

  Future<void> _checkAndShowTutorial() async {
    if (mounted) {
      // Delay to ensure the lesson screen is fully built
      Future.delayed(const Duration(milliseconds: 1500), () async {
        if (mounted) {
          await TutorialService.showLessonTutorial(
            context,
            micButtonKey: _micButtonKey,
            audioButtonKey: _audioButtonKey,
            resetButtonKey: _resetButtonKey,
          );
        }
      });
    }
  }

  Future<void> _loadASRStatus() async {
    setState(() {
      _asrStatus = ASRService.instance.getStatus();
    });
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      await _sentencePlayer.pause(); // Pause sentence audio before recording
      final directory = await getTemporaryDirectory();
      _filePath = path.join(
          directory.path, '${DateTime.now().millisecondsSinceEpoch}.m4a');
      await _audioRecorder.start(
        path: _filePath,
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 44100,
      );
      setState(() {
        isRecording = true;
        // Keep hasRecording true if there was a previous recording
        // Only reset transcription, not the recording state
        if (hasTranscription) hasTranscription = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vous n'avez pas accès au microphone")));
    }
  }

  Future<void> stopRecording() async {
    _filePath = await _audioRecorder.stop();
    if (_filePath != null && mounted) {
      setState(() {
        isRecording = false;
        hasRecording = true;
        _currentPosition = Duration.zero;
        isPlaying = false;
      });
      await _audioPlayer.setSource(DeviceFileSource(_filePath!));
      sendAudioToASR();
    }
  }

  Future<void> togglePlayback() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    } else {
      if (_audioPlayer.state == PlayerState.stopped) {
        await _audioPlayer.setSource(DeviceFileSource(_filePath!));
      }
      if (_currentPosition >= _audioDuration) {
        _currentPosition = Duration.zero;
      }
      await _audioPlayer.seek(_currentPosition);
      await _audioPlayer.resume();
      if (mounted) {
        setState(() {
          isPlaying = true;
        });
      }
    }
  }

  Future<void> partialUpdate(
      Users user, BookUser updatedBookUser, String uid) async {
    final oldBookUser = user.inProgressBooks.firstWhere(
      (b) => b.title == updatedBookUser.title,
      orElse: () => updatedBookUser,
    );

    final newAccSum =
        updatedBookUser.accuracies.fold<double>(0, (p, c) => p + c);
    final newReadingTime = updatedBookUser.readingTime;
    final xpDelta = newAccSum - (oldBookUser.creditedXp ?? 0);
    final readingTimeDelta =
        newReadingTime - (oldBookUser.creditedReadingTime ?? 0);

    if (xpDelta > 0) user.xp += xpDelta.toInt();
    if (readingTimeDelta > 0) user.totalReadingTime += readingTimeDelta.toInt();

    updatedBookUser.creditedXp = newAccSum;
    updatedBookUser.creditedReadingTime = newReadingTime;

    // Use UserSessionService to update user data
    await context.read<UserSessionService>().updateUserData(user);
  }

  void sendAudioToASR() async {
    if (_filePath == null) {
      print('No audio file to transcribe');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      print('=== Starting ASR Transcription ===');
      print('File path: $_filePath');

      // Get current ASR status before transcription
      _loadASRStatus();

      // Use local ASR service instead of API
      String? transcription =
          await ASRService.instance.transcribeAudio(_filePath!);

      // Update ASR status after transcription
      _loadASRStatus();

      if (transcription != null && mounted) {
        List<TextSpan> highlightedSpans =
            getHighlightedTextSpans(transcription);
        setState(() {
          currentTextSpans = highlightedSpans;
          hasTranscription = true;
          _loading = false;
        });
        print('Transcription completed successfully');
      } else {
        setState(() {
          _loading = false;
        });
        print('Transcription failed - no result returned');
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print('Error during transcription: $e');
    }
  }

  List<TextSpan> getHighlightedTextSpans(String transcription) {
    String correctSentence = currentSentence;
    String correctCompare =
        correctSentence.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    String transcriptionCompare =
        transcription.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    // Get alignment operations for correctSentence
    Map<String, dynamic> result =
        computeAlignmentAndDistance(correctCompare, transcriptionCompare);
    List<String> alignment = result['alignment'];

    // Build highlighted spans for correctSentence (original text)
    List<TextSpan> highlightedSpans = [];
    int q = 0; // Index into alignment
    int matching = 0;
    for (int i = 0; i < correctSentence.length; i++) {
      String char = correctSentence[i];
      if (RegExp(r'[\w\s]').hasMatch(char)) {
        if (q < alignment.length) {
          String op = alignment[q];
          bool isCorrect = op == 'match';
          if (isCorrect) matching++;
          highlightedSpans.add(TextSpan(
            text: char,
            style: TextStyle(color: isCorrect ? Colors.green : Colors.red),
          ));
          if (op != 'insertion')
            q++; // Move alignment index only if not an insertion in transcription
        } else {
          // Beyond transcription length, assume incorrect
          highlightedSpans.add(TextSpan(
            text: char,
            style: TextStyle(color: Colors.red),
          ));
        }
      } else {
        // Check if character is punctuation or number - always highlight in green
        bool isPunctuationOrNumber = RegExp(r'[.,!?;:()\-\d]').hasMatch(char) ||
            char == '"' ||
            char == "'";
        highlightedSpans.add(TextSpan(
          text: char,
          style: TextStyle(
            color: isPunctuationOrNumber ? Colors.green : Colors.red,
          ),
        ));
      }
    }

    // Compute accuracy
    double accuracy =
        correctCompare.isEmpty ? 0 : matching / correctCompare.length;
    double adjustedAccuracy = (accuracy * 1.15 > 1.0) ? 1.0 : accuracy * 1.15;
    accuracies.add(adjustedAccuracy);

    return highlightedSpans;
  }

// Alignment function to track operations for correctSentence
  Map<String, dynamic> computeAlignmentAndDistance(String ref, String hyp) {
    int m = ref.length, n = hyp.length;
    List<List<int>> dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    // Initialize DP table
    for (int i = 0; i <= m; i++) dp[i][0] = i; // Deletions
    for (int j = 0; j <= n; j++) dp[0][j] = j; // Insertions

    // Fill DP table
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        int cost = ref[i - 1] == hyp[j - 1] ? 0 : 1;
        dp[i][j] = min(
          dp[i - 1][j] + 1, // Deletion
          min(
              dp[i][j - 1] + 1, // Insertion
              dp[i - 1][j - 1] + cost), // Substitution
        );
      }
    }

    // Backtrace to determine operations for ref (correctSentence)
    List<String> alignment = [];
    int i = m, j = n;
    while (i > 0 || j > 0) {
      if (i > 0 &&
          j > 0 &&
          dp[i][j] == dp[i - 1][j - 1] + (ref[i - 1] == hyp[j - 1] ? 0 : 1)) {
        alignment.add(ref[i - 1] == hyp[j - 1] ? 'match' : 'substitution');
        i--;
        j--;
      } else if (i > 0 && dp[i][j] == dp[i - 1][j] + 1) {
        alignment.add('deletion');
        i--;
      } else if (j > 0 && dp[i][j] == dp[i][j - 1] + 1) {
        // Insertion in transcription, skip for ref
        alignment.add('insertion');
        j--;
      }
    }
    alignment = alignment.reversed.toList();
    return {'alignment': alignment, 'editDistance': dp[m][n]};
  }

  void moveToNextSentence() {
    if (!mounted) return; // Check if widget is still mounted

    // Accumulate time spent on current sentence before moving to next
    if (startTime != null) {
      final sentenceDuration = DateTime.now().difference(startTime!);
      currentSessionTime += sentenceDuration.inSeconds;
    }

    setState(() {
      currentSentenceIndex += 1;
      if (currentSentenceIndex < currentSentences.length) {
        currentImageUrl = bookData!.content[currentPage.toString()]!.imageUrl;
        final audio = bookData!.content[currentPage.toString()]!.sentences
            .map((e) => e.audio)
            .toList();
        currentAudio = audio[currentSentenceIndex];
        currentSentences = List<String>.from(bookData!
            .content[currentPage.toString()]!.sentences
            .map((e) => e.text)).toList();
        currentSentence = currentSentences[currentSentenceIndex];
      } else {
        currentSentenceIndex = 0;
        currentPage += 1;
        final audio = bookData!.content[currentPage.toString()]!.sentences
            .map((e) => e.audio)
            .toList();
        currentAudio = audio[currentSentenceIndex];
        currentImageUrl = bookData!.content[currentPage.toString()]!.imageUrl;
        currentSentences = List<String>.from(bookData!
            .content[currentPage.toString()]!.sentences
            .map((e) => e.text)).toList();
        currentSentence = currentSentences[currentSentenceIndex];
        if (currentPage == bookData!.content.length - 1) lastPage = true;
      }

      // Calculate total reading time for this session
      int totalReadingTime = readingTime + currentSessionTime;

      // Update bookmark with accumulated time
      partialUpdate(
          widget.userdata,
          BookUser(
              lastAccessed: DateTime.now(),
              totalPages: bookData!.content.length,
              title: widget.bookTitle,
              bookmark: currentPage.toString(),
              readingTime: totalReadingTime,
              accuracies: accuracies),
          widget.uid);

      hasTranscription = false;
      hasRecording = false;
      isPlaying = false;
      _currentPosition = Duration.zero;
      currentTextSpans = [TextSpan(text: currentSentence)];

      // Reset start time for the new sentence
      startTime = DateTime.now();
    });
  }

  Future<void> saveProgress() async {
    // Add time spent on current sentence to session time
    if (startTime != null) {
      final sentenceDuration = DateTime.now().difference(startTime!);
      currentSessionTime += sentenceDuration.inSeconds;
      // Reset start time after accumulating
      startTime = DateTime.now();
    }

    int totalReadingTime = readingTime + currentSessionTime;
    if (mounted) setState(() => _sending = true);

    await context.read<ApiFirebaseService>().bookmark(
          widget.uid,
          BookUser(
            lastAccessed: DateTime.now(),
            title: widget.bookTitle,
            bookmark: currentPage.toString(),
            readingTime: totalReadingTime,
            totalPages: bookData!.content.length,
            accuracies: accuracies,
          ),
          widget.userdata,
        );
    if (mounted) setState(() => _sending = false);
  }

  Future<void> bookmarkCurrentPageAndExit(BuildContext context) async {
    // Add time spent on current sentence to session time before exiting
    if (startTime != null) {
      final sentenceDuration = DateTime.now().difference(startTime!);
      currentSessionTime += sentenceDuration.inSeconds;
    }

    int totalReadingTime = readingTime + currentSessionTime;
    setState(() => _sending = true);
    await context.read<ApiFirebaseService>().bookmark(
          widget.uid,
          BookUser(
            lastAccessed: DateTime.now(),
            title: widget.bookTitle,
            bookmark: currentPage.toString(),
            readingTime: totalReadingTime,
            totalPages: bookData!.content.length,
            accuracies: accuracies,
          ),
          widget.userdata,
        );
    setState(() => _sending = false);
    Navigator.pop(context, widget.userdata);
  }

  Future<void> endLesson(BuildContext context) async {
    // Add time spent on current sentence to session time before completing
    if (startTime != null) {
      final sentenceDuration = DateTime.now().difference(startTime!);
      currentSessionTime += sentenceDuration.inSeconds;
    }

    int totalReadingTime = readingTime + currentSessionTime;

    if (!mounted) return; // Check if widget is still mounted

    setState(() => _sending = true);

    Map<String, dynamic> result =
        await context.read<ApiFirebaseService>().markBookAsCompleted(
              widget.uid,
              BookUser(
                  lastAccessed: DateTime.now(),
                  totalPages: bookData!.content.length,
                  title: widget.bookTitle,
                  bookmark: currentPage.toString(),
                  readingTime: totalReadingTime,
                  accuracies: accuracies),
              widget.userdata,
            );

    partialUpdate(
        widget.userdata,
        BookUser(
            lastAccessed: DateTime.now(),
            totalPages: bookData!.content.length,
            title: widget.bookTitle,
            bookmark: currentPage.toString(),
            readingTime: totalReadingTime,
            accuracies: accuracies),
        widget.uid);

    if (!mounted) return; // Check again after async operations

    setState(() => _sending = false);

    final Users updatedUserData = result['userData'];
    final double averageAccuracy = result['averageAccuracy'];

    int totalBookWordCount = bookData!.content.values
        .expand((pageContent) => pageContent.sentences)
        .map((sentence) => sentence.text.split(' ').length)
        .reduce((sum, count) => sum + count);
    double readingTimeInMinutes = totalReadingTime / 60.0;
    String wordPerMin = readingTimeInMinutes > 0
        ? (totalBookWordCount / readingTimeInMinutes).toStringAsFixed(2)
        : "0.00";
    String averageAcc = (averageAccuracy * 100).toStringAsFixed(2);

    final hasMultiple = bookData!.evaluation?.multiple.isNotEmpty ?? false;
    final hasTrueFalse = bookData!.evaluation?.trueorfalse.isNotEmpty ?? false;
    final hasOneImageManyWords =
        bookData!.evaluation?.oneimagemultiplewords.isNotEmpty ?? false;
    final hasOneWordManyImages =
        bookData!.evaluation?.onewordmultipleimages.isNotEmpty ?? false;

    if (hasMultiple ||
        hasTrueFalse ||
        hasOneWordManyImages ||
        hasOneImageManyWords) {
      if (hasOneImageManyWords) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OneImageMultipleWordsPage(
              list: bookData!.evaluation!.oneimagemultiplewords,
              user: updatedUserData,
            ),
          ),
        );
      }
      if (hasMultiple) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultipleChoiceQuestionPage(
              user: updatedUserData,
              questions: bookData!.evaluation!.multiple,
              title: widget.bookTitle,
            ),
          ),
        );
      }
      if (hasOneWordManyImages) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OneWordMultipleImagePage(
              user: updatedUserData,
              list: bookData!.evaluation!.onewordmultipleimages,
            ),
          ),
        );
      }
      if (hasTrueFalse) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrueFalseQuestionPage(
              questions: bookData!.evaluation!.trueorfalse,
              user: updatedUserData,
            ),
          ),
        );
      }
    }

    if (!mounted) return; // Check before showing dialog

    setState(() {
      context.read<ApiFirebaseService>().getUserData(widget.uid);
    });
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        elevation: 16,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            gradient: AppColors.backgroundGradient,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Celebration Header with App Logo
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentOrange.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.jpg',
                          height: 56,
                          width: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      'Aw ni ce!',
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Kalan kaamalen don!',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.wisdomTeal,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Stats Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: AppDecorations.primaryCard.copyWith(
                        gradient: LinearGradient(
                          colors: [AppColors.pureWhite, AppColors.surfaceLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildStatRow(
                            icon: Icons.star,
                            label: 'XP Sɔrɔla',
                            value: '${updatedUserData.xp} XP',
                            color: AppColors.primaryGreen,
                          ),
                          Divider(
                              height: AppSpacing.xl,
                              color: AppColors.lightGrey),
                          _buildStatRow(
                            icon: Icons.timer_outlined,
                            label: 'Waati min taara',
                            value:
                                '${readingTimeInMinutes.toStringAsFixed(1)} minitiw',
                            color: AppColors.wisdomTeal,
                          ),
                          Divider(
                              height: AppSpacing.xl,
                              color: AppColors.lightGrey),
                          _buildStatRow(
                            icon: Icons.speed,
                            label: 'Kalan teliya',
                            value: '$wordPerMin daɲɛw/minitiw',
                            color: AppColors.bookBlue,
                          ),
                          Divider(
                              height: AppSpacing.xl,
                              color: AppColors.lightGrey),
                          _buildStatRow(
                            icon: Icons.check_circle_outline,
                            label: 'Tilennenya',
                            value: '$averageAcc%',
                            color: AppColors.accentOrange,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Continue Button
                    Container(
                      width: double.infinity,
                      decoration: AppDecorations.primaryButtonDecoration,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        child: Text(
                          'Ka taa fɛ',
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
          ),
    );

    Navigator.pop(context, updatedUserData);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle listener
    if (isRecording) {
      _audioRecorder.stop();
    }
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _sentencePlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Pause timer when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (startTime != null) {
        // Accumulate time before pausing
        final sentenceDuration = DateTime.now().difference(startTime!);
        currentSessionTime += sentenceDuration.inSeconds;
        startTime = null; // Pause the timer
      }
    }
    // Resume timer when app comes back to foreground
    else if (state == AppLifecycleState.resumed) {
      if (startTime == null && mounted) {
        // Resume the timer
        startTime = DateTime.now();
      }
    }
  }

  Widget buildAudioSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surfaceLight, AppColors.pureWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey, width: 1),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.pureWhite,
                size: 28,
              ),
              onPressed: togglePlayback,
              tooltip: isPlaying ? 'Pause' : 'Play',
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primaryGreen,
                    inactiveTrackColor: AppColors.lightGrey,
                    thumbColor: AppColors.primaryGreen,
                    overlayColor: AppColors.primaryGreen.withOpacity(0.1),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 16),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _currentPosition.inMilliseconds.toDouble().clamp(
                          0.0,
                          _audioDuration.inMilliseconds.toDouble(),
                        ),
                    min: 0.0,
                    max: _audioDuration.inMilliseconds.toDouble(),
                    onChanged: (double value) {
                      setState(() {
                        final newPosition =
                            Duration(milliseconds: value.toInt());
                        _audioPlayer.seek(newPosition);
                        _currentPosition = newPosition;
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(_currentPosition),
                      style: AppTextStyles.captionText.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formatDuration(_audioDuration),
                      style: AppTextStyles.captionText.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget buildFAB() {
    if (isRecording) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.error, Colors.red.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          key: const ValueKey('stop'),
          heroTag: 'stopFAB',
          onPressed: stopRecording,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.stop, color: Colors.white, size: 28),
        ),
      );
    } else if (hasTranscription) {
      if (lastPage && currentSentenceIndex == currentSentences.length - 1) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.success, AppColors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            key: const ValueKey('end'),
            heroTag: 'endFAB',
            onPressed: () => endLesson(context),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.check, color: Colors.white, size: 28),
          ),
        );
      } else {
        return FloatingHintButton(
          key: const ValueKey('next'),
          onLongPress: startRecording,
          onPressed: moveToNextSentence,
        );
      }
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          key: _micButtonKey,
          heroTag: 'micFAB',
          onPressed: startRecording,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.mic, color: Colors.white, size: 28),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop && lastPage == false) {
          saveProgress();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                _buildMainContent(),
                // Loading dialog overlay
                if (_loading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(AppSpacing.xl),
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryGreen),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Kalan labɛn...',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Aw ka kuma bɛ bamanankan kan na',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop && lastPage == false) {
          saveProgress();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Enhanced App Bar with Logo
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // App Logo
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.jpg',
                            height: 36,
                            width: 36,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.bookTitle,
                              style: AppTextStyles.heading4.copyWith(
                                color: AppColors.primaryGreen,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Kalan ka taa fɛ',
                              style: AppTextStyles.subtitle.copyWith(
                                fontSize: 14,
                                color: AppColors.wisdomTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Debug button
                      // Container(
                      //   decoration: BoxDecoration(
                      //     gradient: LinearGradient(
                      //       colors: [
                      //         AppColors.accentOrange,
                      //         AppColors.accentOrange.withOpacity(0.8)
                      //       ],
                      //       begin: Alignment.topLeft,
                      //       end: Alignment.bottomRight,
                      //     ),
                      //     shape: BoxShape.circle,
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: AppColors.accentOrange.withOpacity(0.3),
                      //         blurRadius: 8,
                      //         offset: const Offset(0, 3),
                      //       ),
                      //     ],
                      //   ),
                      //   child: IconButton(
                      //     onPressed: () async {
                      //       print('\n=== ASR DEBUG STATUS ===');
                      //       final status = ASRService.instance.getStatus();

                      //       status.forEach((key, value) {
                      //         print('$key: $value');
                      //       });

                      //       print('========================\n');

                      //       // Show status in snackbar too
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(
                      //           content: Text(
                      //             'ASR Status: ${status['isInitialized'] ? 'Initialized' : 'Not Initialized'}\n'
                      //             'Platform: ${status['platform']}\n'
                      //             'API Fallback: ${status['allowAPIFallback'] ? 'Enabled' : 'Disabled'}\n'
                      //             'Session Handle: ${status['sessionHandle']}\n'
                      //             'Last Error: ${status['lastError'] ?? 'None'}',
                      //             style:
                      //                 const TextStyle(fontFamily: 'monospace'),
                      //           ),
                      //           duration: const Duration(seconds: 10),
                      //           backgroundColor: AppColors.charcoal,
                      //         ),
                      //       );
                      //     },
                      //     icon: const Icon(Icons.bug_report,
                      //         color: Colors.white, size: 20),
                      //     tooltip: 'ASR Debug',
                      //   ),
                      // ),
                      // const SizedBox(width: AppSpacing.sm),
                      // Exit button moved to the right
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.mediumGrey, AppColors.darkGrey],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mediumGrey.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => bookmarkCurrentPageAndExit(context),
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress Bar - minimal and clean
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                  color: AppColors.pureWhite,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: AppColors.lightGrey,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value:
                            (currentPage + 1) / (bookData?.content.length ?? 1),
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          (currentPage + 1) / (bookData?.content.length ?? 1) <
                                  0.5
                              ? AppColors.accentOrange
                              : AppColors.primaryGreen,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ),

                // Main content area - optimized for maximum image coverage
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(AppSpacing.lg,
                        AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                    decoration: AppDecorations.elevatedCard,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      child: Column(
                        children: [
                          // Image Section - dynamically sized to cover all unused space
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.surfaceLight,
                                    AppColors.offWhite
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Main image covering full area
                                  widget.isOffLine == false
                                      ? CachedNetworkImage(
                                          imageUrl: currentImageUrl,
                                          placeholder: (context, url) => Center(
                                            child: FadeShimmerMaster(
                                              width: double.infinity,
                                              height: double.infinity,
                                              useGradient: true,
                                              fadeTheme: FadeTheme.light,
                                              radius: 0,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: AppColors.lightGrey,
                                            child: Center(
                                              child: Icon(Icons.error,
                                                  color: AppColors.mediumGrey,
                                                  size: 48),
                                            ),
                                          ),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : Image.memory(
                                          base64Decode(currentImageUrl),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),

                                  // Gradient overlay for better text readability
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.3),
                                        ],
                                        stops: const [0.6, 1.0],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Text and Audio Section - compact and efficient
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              minHeight:
                                  120, // Minimum height for text and audio button
                              maxHeight: MediaQuery.of(context).size.height *
                                  0.25, // Maximum 25% of screen
                            ),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.charcoal.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Text Display - scrollable if needed
                                Flexible(
                                  child: SingleChildScrollView(
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 400),
                                        child: RichText(
                                          key: ValueKey(currentSentence),
                                          text: TextSpan(
                                            text: '',
                                            style:
                                                AppTextStyles.heading4.copyWith(
                                              fontSize: 20,
                                              height: 1.4,
                                              color: AppColors.charcoal,
                                            ),
                                            children: currentTextSpans,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.md),

                                // Audio Button - compact but prominent
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.accentGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accentOrange
                                            .withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    key: _audioButtonKey,
                                    iconSize: 28,
                                    icon: const Icon(Icons.volume_up,
                                        color: Colors.white, size: 28),
                                    tooltip: 'Écouter la phrase',
                                    onPressed: () async {
                                      try {
                                        if (widget.isOffLine) {
                                          await _sentencePlayer.setSource(
                                              DeviceFileSource(currentAudio));
                                        } else {
                                          await _sentencePlayer.setSource(
                                              UrlSource(currentAudio));
                                        }
                                        await _sentencePlayer
                                            .play(UrlSource(currentAudio));
                                      } catch (e) {
                                        print(
                                            'Error playing sentence audio: $e');
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Control Panel - optimized to prevent overflow
                Container(
                  height: MediaQuery.of(context).size.height *
                      0.26, // Increased to 26% to accommodate all controls without overflow
                  constraints: BoxConstraints(
                    minHeight: 180, // Minimum height to ensure functionality
                    maxHeight:
                        MediaQuery.of(context).size.height * 0.3, // Maximum cap
                  ),
                  margin: const EdgeInsets.fromLTRB(AppSpacing.lg,
                      AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
                  decoration: AppDecorations.elevatedCard,
                  child: Padding(
                    padding:
                        const EdgeInsets.all(AppSpacing.md), // Balanced padding
                    child: Column(
                      children: [
                        // Top row with reset and main action buttons
                        SizedBox(
                          height: 56, // Fixed height for buttons
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Reset Button - beautifully styled
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.wisdomTeal,
                                      AppColors.lightTeal
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.wisdomTeal.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  key: _resetButtonKey,
                                  iconSize:
                                      26, // Slightly smaller to optimize space
                                  onPressed: () async {
                                    // Reset recording state and hide player
                                    if (isRecording) {
                                      await _audioRecorder.stop();
                                    }
                                    await _audioPlayer.stop();
                                    setState(() {
                                      isRecording = false;
                                      hasRecording = false;
                                      hasTranscription = false;
                                      isPlaying = false;
                                      _currentPosition = Duration.zero;
                                      _audioDuration = Duration.zero;
                                      _filePath = null;
                                      // Reset text spans to show original sentence
                                      currentTextSpans = [
                                        TextSpan(text: currentSentence)
                                      ];
                                    });
                                  },
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white, size: 26),
                                  tooltip: 'Reset',
                                ),
                              ),

                              // Main Action Button - enhanced
                              buildFAB(),
                            ],
                          ),
                        ),

                        const SizedBox(
                            height: AppSpacing.sm), // Optimized spacing

                        // Audio Controls Section - flexible height that expands to fill remaining space
                        Expanded(
                          child: hasRecording
                              ? buildAudioSection()
                              : Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    border: Border.all(
                                      color: AppColors.lightGrey,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isRecording
                                              ? Icons.mic
                                              : Icons.mic_outlined,
                                          color: isRecording
                                              ? AppColors.error
                                              : AppColors.mediumGrey,
                                          size: 28,
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: AppSpacing.sm),
                                            child: Text(
                                              isRecording
                                                  ? 'Ka fɔli ka daminɛ...'
                                                  : 'Aw ka kan dɔn walasa ka kalan daminɛ',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: isRecording
                                                    ? AppColors.error
                                                    : AppColors.mediumGrey,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mediumGrey,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

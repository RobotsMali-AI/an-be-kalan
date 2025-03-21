import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/backend_code/semb_database.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';
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
import 'dart:math';

class LessonScreen extends StatefulWidget {
  final String uid;
  final Users userdata;
  final String bookTitle;
  Book? book;
  bool isOffLine;

  LessonScreen({
    required this.uid,
    required this.userdata,
    required this.bookTitle,
    required this.isOffLine,
    Key? key,
  }) : super(key: key);

  @override
  LessonScreenState createState() => LessonScreenState();
}

class LessonScreenState extends State<LessonScreen> {
  final Record _audioRecorder = Record();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _sentencePlayer =
      AudioPlayer(); // New player for sentence audio

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

  int readingTime = 0;
  DateTime? startTime;

  List<double> accuracies = [];

  @override
  void initState() {
    super.initState();
    setupLesson();
    setupAudioSession();

    // Configure AudioPlayer
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((PlayerState playerState) {
      if (playerState == PlayerState.completed) {
        setState(() {
          isPlaying = false;
          _currentPosition = _audioDuration;
        });
      } else if (mounted) {
        setState(() {
          isPlaying = playerState == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _audioDuration = d;
      });
    });
  }

  Future<void> setupLesson() async {
    Book? response = !widget.isOffLine
        ? await context.read<ApiFirebaseService>().getBook(widget.bookTitle)
        : await context.read<DatabaseHelper>().getBook(widget.bookTitle);
    if (response != null) {
      setState(() {
        bookData = response;
        _loading = false;
      });
      setupInitialPageAndSentence();
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
    } else {
      currentSentences = [];
      currentSentence = '';
      currentTextSpans = [TextSpan(text: "Page not found")];
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
        hasRecording = false;
        if (hasTranscription) hasTranscription = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vous n'avez pas accès au microphone")));
    }
  }

  Future<void> stopRecording() async {
    _filePath = await _audioRecorder.stop();
    if (_filePath != null) {
      setState(() {
        isRecording = false;
        hasRecording = true;
        _currentPosition = Duration.zero;
        isPlaying = false;
      });
      await _audioPlayer.setSource(DeviceFileSource(_filePath!));
      // Duration will be updated via onDurationChanged
      sendAudioToASR();
    }
  }

  Future<void> togglePlayback() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      if (_audioPlayer.state == PlayerState.stopped) {
        await _audioPlayer.setSource(DeviceFileSource(_filePath!));
      }
      if (_currentPosition >= _audioDuration) {
        _currentPosition = Duration.zero;
      }
      await _audioPlayer.seek(_currentPosition);
      await _audioPlayer.resume();
      setState(() {
        isPlaying = true;
      });
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

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(user.toFirestore());
  }

  void sendAudioToASR() async {
    setState(() => _sending = true);
    String? transcription =
        await context.read<ApiFirebaseService>().inferenceASRModel(_filePath!);
    if (transcription != null) {
      List<TextSpan> highlightedSpans = getHighlightedTextSpans(transcription);
      setState(() {
        hasTranscription = true;
        currentTextSpans = highlightedSpans;
        _sending = false;
      });
    } else {
      setState(() => _sending = false);
    }
  }

  // List<TextSpan> getHighlightedTextSpans(String transcription) {
  //   String originalDisplay = currentSentence;
  //   String originalCompare =
  //       currentSentence.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
  //   String transcriptionCompare =
  //       transcription.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

  //   List<TextSpan> highlightedSpans = [];
  //   int matching = 0;
  //   int compareIndex = 0;

  //   for (int i = 0; i < originalDisplay.length; i++) {
  //     String char = originalDisplay[i];
  //     bool isLetterOrSpace = RegExp(r'[\w\s]').hasMatch(char);

  //     if (isLetterOrSpace) {
  //       bool isCorrect = compareIndex < transcriptionCompare.length &&
  //           originalCompare[compareIndex] == transcriptionCompare[compareIndex];
  //       if (isCorrect) matching++;
  //       highlightedSpans.add(TextSpan(
  //         text: char,
  //         style: TextStyle(
  //           color: isCorrect ? Colors.green : Colors.red,
  //         ),
  //       ));
  //       compareIndex++;
  //     } else {
  //       highlightedSpans.add(TextSpan(
  //         text: char,
  //         style: TextStyle(color: Colors.red),
  //       ));
  //     }
  //   }

  //   double accuracy =
  //       originalCompare.isEmpty ? 0 : matching / originalCompare.length;
  //   double adjustedAccuracy = (accuracy * 1.15 > 1.0) ? 1.0 : accuracy * 1.15;
  //   accuracies.add(adjustedAccuracy);

  //   return highlightedSpans;
  // }

  Map<String, dynamic> computeAlignmentAndDistance(String ref, String hyp) {
    int m = ref.length, n = hyp.length;
    // Create dp table.
    List<List<int>> dp = List.generate(
        m + 1, (_) => List.filled(n + 1, 0, growable: false),
        growable: false);

    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        int cost = ref[i - 1] == hyp[j - 1] ? 0 : 1;
        dp[i][j] = min(
            dp[i - 1][j] + 1, min(dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost));
      }
    }

    // Backtrace to compute the alignment (only for reference characters).
    List<String> alignment = [];
    int i = m, j = n;
    while (i > 0 || j > 0) {
      // Check diagonal move.
      if (i > 0 &&
          j > 0 &&
          dp[i][j] == dp[i - 1][j - 1] + (ref[i - 1] == hyp[j - 1] ? 0 : 1)) {
        alignment.add(ref[i - 1] == hyp[j - 1] ? "match" : "substitution");
        i--;
        j--;
      }
      // Check deletion.
      else if (i > 0 && dp[i][j] == dp[i - 1][j] + 1) {
        alignment.add("deletion");
        i--;
      }
      // Check insertion.
      else if (j > 0 && dp[i][j] == dp[i][j - 1] + 1) {
        // For insertion, we don't record an operation for a reference character.
        j--;
      }
    }
    alignment = alignment.reversed.toList();
    return {"alignment": alignment, "editDistance": dp[m][n]};
  }

  List<TextSpan> getHighlightedTextSpans(String transcription) {
    String originalDisplay = currentSentence;
    // Normalize by lowercasing and removing Unicode punctuation only.
    String originalCompare = currentSentence
        .toLowerCase()
        .replaceAll(RegExp(r'\p{P}', unicode: true), '');
    String transcriptionCompare = transcription
        .toLowerCase()
        .replaceAll(RegExp(r'\p{P}', unicode: true), '');

    // Compute alignment and edit distance.
    Map<String, dynamic> result =
        computeAlignmentAndDistance(originalCompare, transcriptionCompare);
    List<String> alignment = result["alignment"];
    int editDistance = result["editDistance"];

    List<TextSpan> highlightedSpans = [];
    int alignmentIndex = 0;
    int matchingCount = 0;
    // Walk through the original display text.
    for (int i = 0; i < originalDisplay.length; i++) {
      String char = originalDisplay[i];
      bool isLetterOrSpace = RegExp(r'\p{L}|\s', unicode: true).hasMatch(char);
      if (isLetterOrSpace) {
        // Get the next operation from the alignment list.
        String op = alignment[alignmentIndex];
        alignmentIndex++;
        bool isCorrect = (op == "match");
        if (isCorrect) matchingCount++;
        highlightedSpans.add(TextSpan(
          text: char,
          style: TextStyle(color: isCorrect ? Colors.green : Colors.red),
        ));
      } else {
        // For punctuation, simply do not highlight.
        highlightedSpans.add(TextSpan(
          text: char,
          style: TextStyle(
              color: Colors.red), // Or Colors.black if you prefer no highlight
        ));
      }
    }

    int total = originalCompare.length;
    // Compute CER-based accuracy: accuracy = 1 - (editDistance / total), but not below 0.
    double accuracy = total == 0 ? 0 : max(0, 1 - (editDistance / total));
    // Boost accuracy by 1.15 and cap at 1.0.
    double adjustedAccuracy = (accuracy * 1.15 > 1.0) ? 1.0 : accuracy * 1.15;
    accuracies.add(adjustedAccuracy);

    return highlightedSpans;
  }

  void moveToNextSentence() {
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
      partialUpdate(
          widget.userdata,
          BookUser(
              lastAccessed: DateTime.now(),
              totalPages: bookData!.content.length,
              title: widget.bookTitle,
              bookmark: currentPage.toString(),
              readingTime: readingTime,
              accuracies: accuracies),
          widget.uid);
      hasTranscription = false;
      hasRecording = false;
      isPlaying = false;
      _currentPosition = Duration.zero;
      currentTextSpans = [TextSpan(text: currentSentence)];
    });
  }

  Future<void> bookmarkCurrentPageAndExit(BuildContext context) async {
    Duration duration = DateTime.now().difference(startTime!);
    readingTime += duration.inSeconds;
    setState(() => _sending = true);
    await context.read<ApiFirebaseService>().bookmark(
          widget.uid,
          BookUser(
            lastAccessed: DateTime.now(),
            title: widget.bookTitle,
            bookmark: currentPage.toString(),
            readingTime: readingTime,
            totalPages: bookData!.content.length,
            accuracies: accuracies,
          ),
          widget.userdata,
        );
    setState(() => _sending = false);
    Navigator.pop(context, widget.userdata);
  }

  Future<void> endLesson(BuildContext context) async {
    Duration duration = DateTime.now().difference(startTime!);
    readingTime += duration.inSeconds;
    double readTime = readingTime / 60;
    int readingTimeInMinutes = readTime.toInt();
    setState(() => _sending = true);

    Map<String, dynamic> result =
        await context.read<ApiFirebaseService>().markBookAsCompleted(
              widget.uid,
              BookUser(
                  lastAccessed: DateTime.now(),
                  totalPages: bookData!.content.length,
                  title: widget.bookTitle,
                  bookmark: currentPage.toString(),
                  readingTime: readingTimeInMinutes,
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
            readingTime: readingTimeInMinutes,
            accuracies: accuracies),
        widget.uid);

    setState(() => _sending = false);

    final Users updatedUserData = result['userData'];
    final double averageAccuracy = result['averageAccuracy'];

    int totalBookWordCount = bookData!.content.values
        .expand((pageContent) => pageContent.sentences)
        .map((sentence) => sentence.text.split(' ').length)
        .reduce((sum, count) => sum + count);
    String wordPerMin =
        (totalBookWordCount / readingTimeInMinutes).toStringAsFixed(2);
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
    setState(() {
      context.read<ApiFirebaseService>().getUserData(widget.uid);
    });
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title with a celebratory icon
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 32),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Aw ni ce!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stat rows for XP, time, speed, and accuracy
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        _buildStatRow(
                          icon: Icons.monetization_on,
                          label: 'XP Sɔrɔla',
                          value:
                              '${context.read<ApiFirebaseService>().userInfo!.xp} XP',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          icon: Icons.timer,
                          label: 'Waati min taara',
                          value:
                              '${readingTimeInMinutes.toStringAsFixed(2)} minutes',
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          icon: Icons.speed,
                          label: 'Kalan teliya',
                          value: '$wordPerMin daɲɛw/minitiw',
                          color: Colors.purple,
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          icon: Icons.check_circle,
                          label: 'Tilennenya',
                          value: '$averageAcc%',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Ka taa fɛ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
          ),
    );

    Navigator.pop(context, updatedUserData);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _sentencePlayer.dispose(); // Dispose of the sentence player
    super.dispose();
  }

  Widget buildAudioSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black,
                  size: 36,
                ),
                onPressed: togglePlayback,
              ),
              const SizedBox(width: 10),
              Text(
                formatDuration(_currentPosition),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const Text(
                ' / ',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              Text(
                formatDuration(_audioDuration),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.black,
              inactiveTrackColor: Colors.blue.shade100,
              thumbColor: Colors.black,
              overlayColor: Colors.black.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
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
                  final newPosition = Duration(milliseconds: value.toInt());
                  _audioPlayer.seek(newPosition);
                  _currentPosition = newPosition;
                });
              },
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
      return FloatingActionButton(
        key: const ValueKey('stop'),
        heroTag: 'stopFAB',
        onPressed: stopRecording,
        backgroundColor: Colors.black,
        child: const Icon(Icons.stop, color: Colors.white),
      );
    } else if (hasTranscription) {
      if (lastPage && currentSentenceIndex == currentSentences.length - 1) {
        return FloatingActionButton(
          key: const ValueKey('end'),
          heroTag: 'endFAB',
          onPressed: () => endLesson(context),
          backgroundColor: Colors.black,
          child: const Icon(Icons.check, color: Colors.white),
        );
      } else {
        return FloatingHintButton(
          key: const ValueKey('next'),
          onLongPress: startRecording,
          onPressed: moveToNextSentence,
        );
      }
    } else {
      return FloatingActionButton(
        key: const ValueKey('mic'),
        heroTag: 'micFAB',
        onPressed: startRecording,
        backgroundColor: Colors.black,
        child: const Icon(Icons.mic, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.withOpacity(0.8),
                Colors.black.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.bookTitle,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => bookmarkCurrentPageAndExit(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: widget.isOffLine == false
                            ? CachedNetworkImage(
                                imageUrl: currentImageUrl,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                fit: BoxFit.contain,
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.38,
                              )
                            : Image.memory(
                                base64Decode(currentImageUrl),
                                fit: BoxFit.contain,
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.38,
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: RichText(
                          key: ValueKey(currentSentence),
                          text: TextSpan(
                            text: '',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.black87,
                            ),
                            children: currentTextSpans,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.black,
                      tooltip: 'Listen to the sentence',
                      onPressed: () async {
                        try {
                          if (widget.isOffLine) {
                            await _sentencePlayer
                                .setSource(DeviceFileSource(currentAudio));
                          } else {
                            await _sentencePlayer
                                .setSource(UrlSource(currentAudio));
                          }
                          await _sentencePlayer.play(UrlSource(currentAudio));
                        } catch (e) {
                          print('Error playing sentence audio: $e');
                        }
                      },
                      child: const Icon(Icons.volume_up, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    if (hasRecording) buildAudioSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.black),
                      value: currentPage / (bookData!.content.length),
                      strokeWidth: 6,
                    ),
                  ),
                  Text(
                    '$currentPage',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: buildFAB(),
              ),
            ),
            if (_sending)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> showCongratulatoryDialog(BuildContext context) async {}

// Helper method to build stat rows
  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

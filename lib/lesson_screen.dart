import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/backend_code/semb_database.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:literacy_app/widgets/floatingHintButton.dart';
import 'package:literacy_app/widgets/multiple_choose_question.dart';
import 'package:literacy_app/widgets/true_or_false_page.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:audio_session/audio_session.dart';

import 'models/Users.dart';

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
    _audioPlayer.setLoopMode(LoopMode.off);

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.playerStateStream.listen((playerState) async {
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.completed) {
        await _audioPlayer.pause();
        setState(() {
          isPlaying = false;
          _currentPosition = _audioDuration;
        });
      } else if (mounted) {
        setState(() {
          isPlaying = playerState.playing;
        });
      }
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
      currentPage = int.parse(bookMarkAt.split(' ')[1]);
      if (currentPage == bookData!.content.length) {
        lastPage = true;
      }
      readingTime = bookProgress.readingTime;
      accuracies = (bookProgress.accuracies as List<dynamic>)
          .map((e) => e as double)
          .toList();
    } else {
      currentPage = 0;
    }

    // Convert currentPage to a string because keys are like "0", "1", etc.
    String pageKey = currentPage.toString();

    if (bookData!.content.containsKey(pageKey)) {
      currentSentences = List<String>.from(
          bookData!.content[pageKey]!.sentences.map((e) => e.text)).toList();
      currentSentence = currentSentences.isNotEmpty
          ? currentSentences[currentSentenceIndex]
          : '';
      currentTextSpans = [TextSpan(text: currentSentence)];
      currentImageUrl = bookData!.content[pageKey]!.imageUrl;
      startTime = DateTime.now();
    } else {
      // Handle the case where the requested page does not exist
      currentSentences = [];
      currentSentence = '';
      currentTextSpans = [TextSpan(text: "Page not found")];
      currentImageUrl = '';
    }

    // currentSentences =
    //     List<String>.from(bookData!.content["Page $currentPage"]!.sentences);
    // currentSentence = currentSentences.isNotEmpty
    //     ? currentSentences[currentSentenceIndex]
    //     : '';
    // currentTextSpans = [TextSpan(text: currentSentence)];
    // currentImageUrl = bookData!.content["Page $currentPage"]!.imageUrl;
    // startTime = DateTime.now();
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

  Future<void> stopRecording() async {
    _filePath = await _audioRecorder.stop();
    if (_filePath != null) {
      setState(() {
        isRecording = false;
        hasRecording = true;
        _currentPosition = Duration.zero;
        isPlaying = false;
      });
      await _audioPlayer.setFilePath(_filePath!);
      setState(() {
        _audioDuration = _audioPlayer.duration ?? Duration.zero;
      });
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
      if (_audioPlayer.processingState == ProcessingState.idle) {
        await _audioPlayer.setFilePath(_filePath!);
      }
      if (_audioPlayer.processingState == ProcessingState.completed) {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.play();
      setState(() {
        isPlaying = true;
      });
    }
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
  //   List<String> originalWords = currentSentence.split(' ');
  //   List<String> transcribedWords = transcription.split(' ');
  //   int correctWordCount = 0;

  //   List<TextSpan> highlightedSpans = [];
  //   for (var word in originalWords) {
  //     bool isCorrect = transcribedWords.contains(word);
  //     if (isCorrect) correctWordCount++;
  //     highlightedSpans.add(TextSpan(
  //       text: '$word ',
  //       style: TextStyle(
  //         color: isCorrect ? Colors.green : Colors.red,
  //       ),
  //     ));
  //   }
  //   accuracies.add(correctWordCount / originalWords.length);
  //   return highlightedSpans;
  // }

  List<TextSpan> getHighlightedTextSpans(String transcription) {
    // Keep the original sentence intact for display
    String originalDisplay = currentSentence;
    // Modified versions for comparison only
    String originalCompare =
        currentSentence.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    String transcriptionCompare =
        transcription.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    List<TextSpan> highlightedSpans = [];
    int matching = 0;
    int compareIndex = 0;

    // Loop through the original sentence (with casing and punctuation)
    for (int i = 0; i < originalDisplay.length; i++) {
      String char = originalDisplay[i];
      bool isLetterOrSpace = RegExp(r'[\w\s]').hasMatch(char);

      if (isLetterOrSpace) {
        // Compare using the modified versions
        bool isCorrect = compareIndex < transcriptionCompare.length &&
            originalCompare[compareIndex] == transcriptionCompare[compareIndex];
        if (isCorrect) matching++;
        highlightedSpans.add(TextSpan(
          text: char, // Use the original character for display
          style: TextStyle(
            color: isCorrect ? Colors.green : Colors.red,
          ),
        ));
        compareIndex++;
      } else {
        // Punctuation marks: always red as transcription doesn’t include them
        highlightedSpans.add(TextSpan(
          text: char,
          style: TextStyle(color: Colors.red),
        ));
      }
    }

    // Calculate accuracy based on the comparison strings
    double accuracy =
        originalCompare.isEmpty ? 0 : matching / originalCompare.length;
    double adjustedAccuracy = (accuracy * 1.15 > 1.0) ? 1.0 : accuracy * 1.15;
    accuracies.add(adjustedAccuracy);

    return highlightedSpans;
  }

  void moveToNextSentence() {
    setState(() {
      currentSentenceIndex += 1;
      if (currentSentenceIndex < currentSentences.length) {
        currentImageUrl = bookData!.content[currentPage]!.imageUrl;
        currentSentences = List<String>.from(
                bookData!.content[currentPage]!.sentences.map((e) => e.text))
            .toList();
        currentSentence = currentSentences[currentSentenceIndex];
        // currentSentence = currentSentences[currentSentenceIndex];
      } else {
        currentSentenceIndex = 0;
        currentPage += 1;
        currentImageUrl = bookData!.content[currentPage]!.imageUrl;
        currentSentences = List<String>.from(
                bookData!.content[currentPage]!.sentences.map((e) => e.text))
            .toList();
        currentSentence = currentSentences[currentSentenceIndex];
        if (currentPage == bookData!.content.length) lastPage = true;
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
    final int earnedXp = result['earnedXp'];
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

    if (hasMultiple || hasTrueFalse) {
      if (hasMultiple) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultipleChoiceQuestionPage(
              questions: bookData!.evaluation!.multiple,
              title: widget.bookTitle,
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
            ),
          ),
        );
      }
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Text('You gained $earnedXp XP from this lesson.\n\n'
            'Completed in ${readingTimeInMinutes.toStringAsFixed(2)} minutes\n'
            'Reading speed: $wordPerMin words/min\n'
            'Accuracy: $averageAcc%'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );

    Navigator.pop(context, updatedUserData);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Updated Audio Section with Custom Styling
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
        heroTag: 'stopFAB', // Unique tag
        onPressed: stopRecording,
        backgroundColor: Colors.black,
        child: const Icon(Icons.stop, color: Colors.white),
      );
    } else if (hasTranscription) {
      if (lastPage && currentSentenceIndex == currentSentences.length - 1) {
        return FloatingActionButton(
          key: const ValueKey('end'),
          heroTag: 'endFAB', // Unique tag
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
        heroTag: 'micFAB', // Unique tag
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
      // Keep the existing AppBar
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
      // Improved body with gradient background
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
                    // Polished Image Display
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
                    // Beautiful Text Display
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
                    // Stylish Volume Button
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.black,
                      tooltip: 'Listen to the sentence',
                      onPressed: () {
                        // Add text-to-speech functionality here
                      },
                      child: const Icon(Icons.volume_up, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    // Refined Audio Section
                    if (hasRecording) buildAudioSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            // Enhanced Progress Indicator
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
            // Dynamic FAB with Animation
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
            // Loading Overlay
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
}

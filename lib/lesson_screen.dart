import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/backend_code/semb_database.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:literacy_app/widgets/floatingHintButton.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart'; // For getting the temporary directory
import 'package:path/path.dart' as path;

import 'models/Users.dart'; // For manipulating file paths

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

  // State changing variables
  bool isRecording = false;
  bool hasRecording = false;
  bool isInProgress = false;
  bool hasTranscription = false;
  bool lastPage = false;
  bool _sending = false;
  bool _loading = true;
  // Audio Recording related state variables
  bool isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

  // lessonScreen components variables
  String? _filePath;
  Book? bookData;
  List<String> currentSentences = [];
  int currentPage = 0;
  int currentSentenceIndex = 0;
  String currentSentence = '';
  List<TextSpan> currentTextSpans = []; // State variable for TextSpans
  String currentImageUrl = '';

  // Duration measurement variables
  int readingTime = 0; // Time passed on this book
  DateTime? startTime;

  // Other variables
  List<double> accuracies = [];

  @override
  void initState() {
    super.initState();
    setupLesson();

    // Set loop mode to off
    _audioPlayer.setLoopMode(LoopMode.off);

    // Audio player listeners
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.playerStateStream.listen((playerState) async {
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        await _audioPlayer.pause(); // Explicitly pause the player
        setState(() {
          isPlaying = false;
          _currentPosition = _audioDuration;
        });
      } else {
        if (mounted) {
          setState(() {
            isPlaying = playerState.playing;
          });
        }
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
    } else {
      // Handle error if book data cannot be retrieved
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
      // Set reading time and previous accuracies
      readingTime = bookProgress.readingTime;
      accuracies = (bookProgress.accuracies as List<dynamic>)
          .map((e) => e as double)
          .toList();
    } else {
      currentPage = 1;
    }

    currentSentences =
        List<String>.from(bookData!.content["Page $currentPage"]!.sentences);
    currentSentence = currentSentences.isNotEmpty
        ? currentSentences[currentSentenceIndex]
        : '';

    // Initialize currentTextSpans with the current sentence
    currentTextSpans = [TextSpan(text: currentSentence)];

    // Get the image URL for the current page
    currentImageUrl = bookData!.content["Page $currentPage"]!.imageUrl;

    startTime = DateTime.now();
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      // Get the temporary directory of the device
      final directory = await getTemporaryDirectory();
      // Create a unique file path with the .wav extension
      _filePath = path.join(
        directory.path,
        '${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      await _audioRecorder.start(
        path: _filePath,
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 44100,
      );
      setState(() {
        isRecording = true;
        hasRecording = false;
        if (hasTranscription) {
          hasTranscription = false;
        }
      });
    }
  }

  Future<void> stopRecording() async {
    _filePath = await _audioRecorder.stop();
    if (_filePath != null) {
      setState(() {
        isRecording = false;
        hasRecording = true;
        _currentPosition = Duration.zero;
        isPlaying = false; // Ensure isPlaying is false
      });
      // Prepare the audio player with the new file
      await _audioPlayer.setFilePath(_filePath!);
      // Update the total duration
      setState(() {
        _audioDuration = _audioPlayer.duration ?? Duration.zero;
      });
      // Automatically send audio for transcription
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
    // Set loading status to show progress Indicator
    setState(() {
      _sending = true;
    });

    String? transcription =
        await context.read<ApiFirebaseService>().inferenceASRModel(_filePath!);
    if (transcription != null) {
      List<TextSpan> highlightedSpans = getHighlightedTextSpans(transcription);

      setState(() {
        hasTranscription = true; // Set to true once transcription is processed
        currentTextSpans = highlightedSpans; // Update state variable
        _sending = false;
      });
    } else {
      // Handle error transcription is null
      setState(() {
        _sending = false;
      });
    }
  }

  List<TextSpan> getHighlightedTextSpans(String transcription) {
    List<String> originalWords = currentSentence.split(' ');
    List<String> transcribedWords = transcription.split(' ');
    int correctWordCount = 0;

    // Highlighting logic
    List<TextSpan> highlightedSpans = [];
    for (var word in originalWords) {
      bool isCorrect = transcribedWords.contains(word);
      if (isCorrect) {
        correctWordCount++;
      }
      highlightedSpans.add(TextSpan(
        text: '$word ',
        style: TextStyle(
          color: isCorrect ? Colors.green : Colors.red,
        ),
      ));
    }
    // Add correct words percentage to the list of Accuracies
    accuracies.add(correctWordCount / originalWords.length);

    return highlightedSpans;
  }

  void moveToNextSentence() {
    setState(() {
      currentSentenceIndex += 1;
      if (currentSentenceIndex < currentSentences.length) {
        currentSentence = currentSentences[currentSentenceIndex];
      } else {
        currentSentenceIndex = 0;
        currentPage += 1;
        // Update the image URL for the new page
        currentImageUrl = bookData!.content["Page $currentPage"]!.imageUrl;

        currentSentences = List<String>.from(
            bookData!.content["Page $currentPage"]!.sentences);
        currentSentence = currentSentences[currentSentenceIndex];
        if (currentPage == bookData!.content.length) {
          lastPage = true;
        }
      }
      hasTranscription = false;
      hasRecording = false;
      isPlaying = false;
      _currentPosition = Duration.zero;
      currentTextSpans = [
        TextSpan(text: currentSentence)
      ]; // Reset to default sentence
    });
  }

  Future<void> bookmarkCurrentPageAndExit(BuildContext context) async {
    // Calculate duration
    Duration duration = DateTime.now().difference(startTime!);
    readingTime += duration.inSeconds;

    // Set loading status to show progress Indicator
    setState(() {
      _sending = true;
    });

    await context.read<DatabaseHelper>();

    await context.read<ApiFirebaseService>().bookmark(
          widget.uid,
          BookUser(
            lastAccessed: DateTime.now(),
            title: widget.bookTitle,
            bookmark: 'Page $currentPage',
            readingTime: readingTime,
            totalPages: bookData!.content.length,
            accuracies: accuracies,
          ),
          widget.userdata,
        );

    setState(() {
      _sending = false;
    });

    Navigator.pop(context, widget.userdata);
  }

  Future<void> endLesson(BuildContext context) async {
    // Calculate duration
    Duration duration = DateTime.now().difference(startTime!);
    readingTime += duration.inSeconds;
    double readTime = readingTime / 60;
    int readingTimeInMinutes = readTime.toInt();

    // Set loading status to show progress Indicator
    setState(() {
      _sending = true;
    });

    Map<String, dynamic> result =
        await context.read<ApiFirebaseService>().markBookAsCompleted(
              widget.uid,
              BookUser(
                  lastAccessed: DateTime.now(),
                  totalPages: bookData!.content.length,
                  title: widget.bookTitle,
                  bookmark: 'Page $currentPage',
                  readingTime: readingTimeInMinutes,
                  accuracies: accuracies),
              widget.userdata,
            );

    setState(() {
      _sending = false;
    });

    Map<String, dynamic> data = {
      'userData': result['userData'],
      'earnedXp': result['earnedXp'],
      'averageAccuracy': result['averageAccuracy'],
    };

    Users updatedUserData = data['userData'];
    int earnedXp = data['earnedXp'];
    double averageAccuracy = data['averageAccuracy'];

    // Calculate total word count of the book
    int totalBookWordCount = bookData!.content.values
        .expand((pageContent) => pageContent.sentences)
        .map((sentence) => sentence.split(' ').length)
        .reduce((sum, count) => sum + count);
    // Calculate reading speed
    String wordPerMin =
        (totalBookWordCount / readingTimeInMinutes).toStringAsFixed(2);
    // Calculate average accuracy
    String averageAcc = (averageAccuracy * 100).toStringAsFixed(2);

    // Show a dialog to congratulate the user
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: Text(
              'You gained $earnedXp XP from this lesson. The book was completed in ${readingTimeInMinutes.toStringAsFixed(2)} minutes, '
              'with an average reading speed of $wordPerMin words per minute and an average accuracy of $averageAcc%'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog and return to HomeScreen
                Navigator.pop(context); // This closes the dialog
                Navigator.pop(context, updatedUserData); // This pops the screen
              },
              child: const Icon(
                Icons.home,
                color: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget buildAudioSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Play/Pause button and duration timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black87,
                  size: 30,
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
          // Progress line using Slider
          Slider(
            value: _currentPosition.inMilliseconds.toDouble().clamp(
                  0.0,
                  _audioDuration.inMilliseconds.toDouble(),
                ),
            min: 0.0,
            max: _audioDuration.inMilliseconds.toDouble(),
            activeColor: Colors.purple,
            inactiveColor: Colors.purple.shade200,
            onChanged: (double value) {
              setState(() {
                final newPosition = Duration(milliseconds: value.toInt());
                _audioPlayer.seek(newPosition);
                _currentPosition = newPosition;
              });
            },
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
      // Show stop icon
      return FloatingActionButton(
        onPressed: stopRecording,
        backgroundColor: Colors.grey[350],
        child: const Icon(Icons.stop, color: Colors.black),
      );
    } else if (hasTranscription) {
      if (lastPage && currentSentenceIndex == currentSentences.length - 1) {
        // Show End Lesson icon
        return FloatingActionButton(
          onPressed: () => endLesson(context),
          backgroundColor: Colors.grey[350],
          child: const Icon(Icons.check, color: Colors.black),
        );
      } else {
        // Show Next icon, with long-press to re-record
        return FloatingHintButton(
          onLongPress: startRecording,
          onPressed: moveToNextSentence,
        );
      }
    } else {
      // Default state, show mic icon to start recording
      return FloatingActionButton(
        onPressed: startRecording,
        backgroundColor: Colors.grey[350],
        child: const Icon(Icons.mic, color: Colors.black),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Show loading spinner for a few milliseconds before bookData loads
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
        title: Text(
          widget.bookTitle,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => bookmarkCurrentPageAndExit(context),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  // Image with loading indicator
                  widget.isOffLine == false
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              currentImageUrl,
                              fit: BoxFit.contain,
                              width: MediaQuery.of(context).size.width * 1.0,
                              height: MediaQuery.of(context).size.height * 0.38,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          ],
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.memory(
                              base64Decode(currentImageUrl),
                              fit: BoxFit.contain,
                              width: MediaQuery.of(context).size.width * 1.0,
                              height: MediaQuery.of(context).size.height * 0.38,
                            ),
                          ],
                        ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: '',
                      style: const TextStyle(fontSize: 21, color: Colors.black),
                      children:
                          currentTextSpans, // Use state-dependent variable
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[350], // Background color
                      shape: BoxShape.circle, // Makes it circular
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.black87),
                      onPressed: () {
                        // Add functionality for volume up button
                      },
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (hasRecording) buildAudioSection(),
                  const SizedBox(height: 65),
                  if (!hasRecording) const SizedBox(height: 115),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 20,
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black87),
              value: currentPage /
                  (bookData!.content.length), // Calculate progress
            ),
          ),
          Positioned(
            bottom: 0,
            right: 20,
            width: 65,
            height: 65,
            child: buildFAB(),
          ),
          if (_sending)
            const Center(
              heightFactor: 17,
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

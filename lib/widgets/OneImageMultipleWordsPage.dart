import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// Data class to hold word information
class Word {
  final String text;
  final String audioPath;
  final bool isCorrect;

  Word({required this.text, required this.audioPath, required this.isCorrect});
}

// Data class for the page content
class ImageWordsData {
  final String imagePath;
  final String mainAudioPath;
  final List<Word> words;

  ImageWordsData({
    required this.imagePath,
    required this.mainAudioPath,
    required this.words,
  });
}

class OneImageMultipleWordsPage extends StatefulWidget {
  const OneImageMultipleWordsPage({super.key});

  @override
  _OneImageMultipleWordsPageState createState() =>
      _OneImageMultipleWordsPageState();
}

class _OneImageMultipleWordsPageState extends State<OneImageMultipleWordsPage> {
  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // List of levels
  final List<ImageWordsData> levels = [
    ImageWordsData(
      imagePath: 'assets/chicken.jpg',
      mainAudioPath: 'sounds/chicken.mp3',
      words: [
        Word(text: 'Chicken', audioPath: 'sounds/chicken.mp3', isCorrect: true),
        Word(text: 'Nest', audioPath: 'sounds/nest.mp3', isCorrect: false),
        Word(text: 'Dog', audioPath: 'sounds/dog.mp3', isCorrect: false),
        Word(text: 'Car', audioPath: 'sounds/car.mp3', isCorrect: false),
      ],
    ),
    ImageWordsData(
      imagePath: 'assets/chicken.jpg',
      mainAudioPath: 'sounds/chicken.mp3',
      words: [
        Word(text: 'Chicken', audioPath: 'sounds/chicken.mp3', isCorrect: true),
        Word(text: 'Tractor', audioPath: 'sounds/error.mp3', isCorrect: false),
        Word(text: 'City', audioPath: 'sounds/error.mp3', isCorrect: false),
        Word(text: 'Beach', audioPath: 'sounds/error.mp3', isCorrect: false),
      ],
    ),
    // Add more levels as needed
  ];

  // State variables
  int currentLevel = 0;
  Set<String> selectedWords = {};
  bool hasChecked = false;

  // Play audio function
  Future<void> _playAudio(String path) async {
    await _audioPlayer.play(AssetSource(path));
  }

  // Check selection and handle level progression
  void _checkSelection() {
    setState(() {
      hasChecked = true;
    });

    final currentData = levels[currentLevel];
    // Check if all correct words are selected and no incorrect words are selected
    bool allCorrectSelected = currentData.words
        .where((word) => word.isCorrect)
        .every((word) => selectedWords.contains(word.text));
    bool noIncorrectSelected = currentData.words
        .where((word) => !word.isCorrect)
        .every((word) => !selectedWords.contains(word.text));

    if (allCorrectSelected && noIncorrectSelected) {
      // Correct selection: proceed to next level or show completion
      if (currentLevel < levels.length - 1) {
        setState(() {
          currentLevel++;
          hasChecked = false;
          selectedWords.clear();
        });
      } else {
        // All levels completed
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Congratulations!'),
            content: const Text('You have completed all levels.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  // Determine background color based on selection and correctness
  Color _getBackgroundColor(Word word) {
    if (!hasChecked) {
      return Colors.white;
    } else {
      if (word.isCorrect && selectedWords.contains(word.text)) {
        return Colors.green.withOpacity(0.2); // Correct and selected
      } else if (!word.isCorrect && selectedWords.contains(word.text)) {
        return Colors.red.withOpacity(0.2); // Incorrect and selected
      } else if (word.isCorrect && !selectedWords.contains(word.text)) {
        return Colors.yellow.withOpacity(0.2); // Correct but unselected
      } else {
        return Colors.white; // No feedback needed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImageWordsData currentData = levels[currentLevel];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${currentLevel + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Image
              Expanded(
                flex: 2,
                child: Center(
                  child: Image.asset(
                    currentData.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Main audio button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      color: Colors.purple,
                      size: 40,
                    ),
                    onPressed: () => _playAudio(currentData.mainAudioPath),
                  ),
                  const Text(
                    'Listen to the story',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Words list
              Expanded(
                flex: 3,
                child: ListView.builder(
                  itemCount: currentData.words.length,
                  itemBuilder: (context, index) {
                    final word = currentData.words[index];
                    return _buildWordCard(word);
                  },
                ),
              ),
            ],
          ),
          // Check button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: hasChecked ? null : _checkSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Check',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build individual word card
  Widget _buildWordCard(Word word) {
    final bool isSelected = selectedWords.contains(word.text);
    final Color backgroundColor = _getBackgroundColor(word);

    return GestureDetector(
      onTap: hasChecked
          ? null
          : () {
              setState(() {
                if (isSelected) {
                  selectedWords.remove(word.text);
                } else {
                  selectedWords.add(word.text);
                }
              });
            },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            hasChecked
                ? Icon(
                    word.isCorrect ? Icons.check : Icons.close,
                    color: word.isCorrect ? Colors.green : Colors.red,
                  )
                : Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                word.text,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.purple),
              onPressed: () => _playAudio(word.audioPath),
            ),
          ],
        ),
      ),
    );
  }
}

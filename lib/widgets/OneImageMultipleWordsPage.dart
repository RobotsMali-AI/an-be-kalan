import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/oneimagemultiplewordsquestion.dart';
import 'package:provider/provider.dart';

class OneImageMultipleWordsPage extends StatefulWidget {
  const OneImageMultipleWordsPage(
      {required this.list, required this.user, super.key});
  final List<OneImageMultipleWordsQuestion> list;
  final Users user;

  @override
  _OneImageMultipleWordsPageState createState() =>
      _OneImageMultipleWordsPageState();
}

class _OneImageMultipleWordsPageState extends State<OneImageMultipleWordsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late List<OneImageMultipleWordsQuestion> levels;
  int currentLevel = 0;
  String? selectedOption;
  bool hasChecked = false;
  int correctAnswers = 0; // Track correct answers

  @override
  void initState() {
    super.initState();
    levels = widget.list;
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Clean up AudioPlayer
    super.dispose();
  }

  // Check the user's selection and play appropriate sound
  void _checkSelection() async {
    setState(() {
      hasChecked = true;
    });

    final currentQuestion = levels[currentLevel];
    if (selectedOption == currentQuestion.answer) {
      correctAnswers++;
      widget.user.xp += 1;
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } else {
      await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
    }
  }

  // Proceed to the next question or show the final dialog
  void _nextQuestion() async {
    if (currentLevel < levels.length - 1) {
      setState(() {
        currentLevel++;
        hasChecked = false;
        selectedOption = null;
      });
    } else {
      await context
          .read<ApiFirebaseService>()
          .saveUserData(widget.user.uid!, widget.user);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Aw ni ce!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'I ye hakɛw $correctAnswers/${levels.length} dafa. I ye dɔnniya sɔrɔ $correctAnswers!',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Return to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'N sɔnna',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  // Determine background color for visual feedback
  Color _getBackgroundColor(String option, String answer) {
    if (!hasChecked) {
      return Colors.white;
    } else if (option == answer) {
      return Colors.green.withOpacity(0.2); // Correct answer
    } else if (option == selectedOption) {
      return Colors.red.withOpacity(0.2); // Wrong answer selected
    } else {
      return Colors.white; // No feedback
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = levels[currentLevel];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
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
                'Hakɛ ${currentLevel + 1}',
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  currentQuestion.question,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Image.network(
                    currentQuestion.image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 3,
                child: ListView.builder(
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, index) {
                    final option = currentQuestion.options[index];
                    return _buildOptionCard(option, currentQuestion.answer);
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: hasChecked || selectedOption == null
                        ? null
                        : _checkSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Sɛgɛsɛgɛli',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
                if (hasChecked) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        currentLevel < levels.length - 1 ? 'Nata' : 'Dafa',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build option card with enhanced design
  Widget _buildOptionCard(String option, String answer) {
    final bool isSelected = selectedOption == option;
    final Color backgroundColor = _getBackgroundColor(option, answer);

    return Card(
      elevation:
          isSelected && !hasChecked ? 4 : 2, // Higher elevation when selected
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: hasChecked
            ? Icon(
                option == answer ? Icons.check : Icons.close,
                color: option == answer ? Colors.green : Colors.red,
              )
            : Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? Colors.black : Colors.grey,
              ),
        title: Text(
          option,
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
        onTap: hasChecked
            ? null
            : () {
                setState(() {
                  selectedOption = option;
                });
              },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/oneimagemultiplewordsquestion.dart';
import 'package:provider/provider.dart';

class OneImageMultipleWordsPage extends StatefulWidget {
  OneImageMultipleWordsPage(
      {required this.list, required this.user, super.key});
  List<OneImageMultipleWordsQuestion> list;
  Users user;

  @override
  _OneImageMultipleWordsPageState createState() =>
      _OneImageMultipleWordsPageState();
}

class _OneImageMultipleWordsPageState extends State<OneImageMultipleWordsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Updated levels using OneImageMultipleWordsQuestion
  List<OneImageMultipleWordsQuestion> levels = [];

  // State variables
  int currentLevel = 0;
  String? selectedOption; // Single selection instead of Set
  bool hasChecked = false;

  @override
  void initState() {
    super.initState();
    levels = widget.list;
  }

  // Play audio function (kept for potential future use)
  Future<void> _playAudio(String path) async {
    await _audioPlayer.play(AssetSource(path));
  }

  // Check selection and handle progression
  void _checkSelection() async {
    setState(() {
      hasChecked = true;
    });

    final currentQuestion = levels[currentLevel];
    if (selectedOption == currentQuestion.answer) {
      // Increment XP only for correct answers
      widget.user.xp += 1;
    }
  }

  void _nextQuestion() async {
    if (currentLevel < levels.length - 1) {
      setState(() {
        currentLevel++;
        hasChecked = false;
        selectedOption = null;
      });
    } else {
      // Save user data and show congratulatory dialog at the end
      await context
          .read<ApiFirebaseService>()
          .saveUserData(widget.user.uid!, widget.user);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title with icon
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
                  // Content with score
                  Flexible(
                    child: Text(
                      'I ye nivow bɛɛ dafa. I ye wari sɔrɔ ${widget.user.xp} XP!',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Return to previous screen
                      },
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
                        'N SƆNNA',
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
      );
    }
  }

  // Determine background color for feedback
  Color _getBackgroundColor(String option, String answer) {
    if (!hasChecked) {
      return Colors.white;
    } else {
      if (option == answer) {
        return Colors.green.withOpacity(0.2); // Correct answer
      } else if (option == selectedOption) {
        return Colors.red.withOpacity(0.2); // Selected but wrong
      } else {
        return Colors.white; // No feedback
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final OneImageMultipleWordsQuestion currentQuestion = levels[currentLevel];
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
                'Hakɛya ${currentLevel + 1}',
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
              // Display the question
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  currentQuestion.question,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Image
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
              // Options list
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
          // Check button and Next button
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Waritasɛbɛn',
                      style: TextStyle(fontSize: 18),
                    ),
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        currentLevel < levels.length - 1 ? 'Gɛlɛn' : 'Dafa',
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

  // Build individual option card
  Widget _buildOptionCard(String option, String answer) {
    final bool isSelected = selectedOption == option;
    final Color backgroundColor = _getBackgroundColor(option, answer);

    return GestureDetector(
      onTap: hasChecked
          ? null
          : () {
              setState(() {
                selectedOption = option;
                if (option == answer) {
                  widget.user.xp += 1;
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
                    option == answer ? Icons.check : Icons.close,
                    color: option == answer ? Colors.green : Colors.red,
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
                option,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            // No audio button since options lack audio paths
          ],
        ),
      ),
    );
  }
}

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
  late List<int> questionOrder; // List to store shuffled indices
  int currentLevel = 0;
  String? selectedOption;
  bool hasChecked = false;
  int correctAnswers = 0; // Track correct answers

  @override
  void initState() {
    super.initState();
    // Initialize the question order with shuffled indices
    questionOrder = List.generate(widget.list.length, (index) => index)
      ..shuffle();
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

    final currentQuestion = widget.list[questionOrder[currentLevel]];
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
    if (currentLevel < widget.list.length - 1) {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Aw ni ce!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'I ye hakɛw $correctAnswers/${widget.list.length} dafa. I ye dɔnniya sɔrɔ $correctAnswers!',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'N sɔnna',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
      return Colors.black.withOpacity(0.1);
    } else if (option == selectedOption) {
      return Colors.black.withOpacity(0.05);
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.list[questionOrder[currentLevel]];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hakɛ ${currentLevel + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  currentQuestion.question,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      currentQuestion.image,
                      fit: BoxFit.contain,
                    ),
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sɛgɛsɛgɛli',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (hasChecked) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          currentLevel < widget.list.length - 1
                              ? 'Nata'
                              : 'Dafa',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: hasChecked
              ? Icon(
                  option == answer ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 24,
                )
              : Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: Colors.white,
                  size: 24,
                ),
        ),
        title: Text(
          option,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
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

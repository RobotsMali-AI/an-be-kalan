import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';

class ChooseCorrectSpellPage extends StatefulWidget {
  const ChooseCorrectSpellPage({super.key});

  @override
  State<ChooseCorrectSpellPage> createState() => _ChooseCorrectSpellPageState();
}

class _ChooseCorrectSpellPageState extends State<ChooseCorrectSpellPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfettiController _confettiController =
      ConfettiController(duration: 2.seconds);
  final List<Map<String, dynamic>> spells = [
    {
      'word': 'kunkolo',
      'options': ['kunkolo', 'kankolo', 'kunkɔrɔ'],
      'image': 'assets/nkalanIm/tete.jpg',
      'audio': 'nkalanSound/tete.mp3',
      'hint': 'farikolo bɛɛ sanfɛ.',
      'partial': 'kun' // For word completion hint
    },
    {
      'word': 'cɛkisɛ',
      'options': ['cɛmisɛn', 'cɛkisɛ', 'camancɛ'],
      'image': 'assets/nkalanIm/tronc.jpg',
      'audio': 'nkalanSound/tronc.mp3',
      'hint': 'Kun ni sen cɛ.',
      'partial': 'cɛk' // For word completion hint
    },
    {
      'word': 'joli',
      'options': ['jaba', 'joli', 'fɔli'],
      'image': 'assets/nkalanIm/sang.jpg',
      'audio': 'nkalanSound/sang.mp3',
      'hint': 'ji bileman cɔri.',
      'partial': 'jo' // For word completion hint
    },
    {
      'word': 'cakɛda',
      'options': ['ciden', 'caaman', 'cakɛda'],
      'image': 'assets/nkalanIm/service.jpg',
      'audio': 'nkalanSound/service.mp3',
      'hint': 'baara ke kɛ yen.',
      'partial': 'cakɛ' // For word completion hint
    },
    {
      'word': 'kelen',
      'options': ['kelen', 'kɛlɛ', 'kalan'],
      'image': 'assets/nkalanIm/un.jpg',
      'audio': 'nkalanSound/un.mp3',
      'hint': 'daminɛ.',
      'partial': 'kel' // For word completion hint
    },
    {
      'word': 'baara',
      'options': ['barada', 'bamankan', 'baara'],
      'image': 'assets/nkalanIm/travail.jpg',
      'audio': 'nkalanSound/travail.mp3',
      'hint': 'a bɛ kɛ ni fanga ye.',
      'partial': 'baa' // For word completion hint
    },
    {
      'word': 'kɔkɔ',
      'options': ['kɔrɔ', 'kɔkɔ', 'kolo'],
      'image': 'assets/nkalanIm/sel.jpg',
      'audio': 'nkalanSound/sel.mp3',
      'hint': 'a kadi.',
      'partial': 'kɔ' // For word completion hint
    },
    {
      'word': 'cɛkɔrɔba',
      'options': ['jɔyɔrɔ', 'cɛkisɛ', 'cɛkɔrɔba'],
      'image': 'assets/nkalanIm/vieux.jpg',
      'audio': 'nkalanSound/vieux.mp3',
      'hint': 'san caaman.',
      'partial': 'cɛkɔr' // For word completion hint
    },
    {
      'word': 'basiki',
      'options': ['basiki', 'baraji', 'busan'],
      'image': 'assets/nkalanIm/tranquile.jpg',
      'audio': 'nkalanSound/tranquille.mp3',
      'hint': 'ka to yɔrɔkelen.',
      'partial': 'bas' // For word completion hint
    },
    {
      'word': 'kini',
      'options': ['kini', 'kin', 'kelen'],
      'image': 'assets/nkalanIm/riz.jpg',
      'audio': 'nkalanSound/riz.mp3',
      'hint': 'kisɛ jɛɛman.',
      'partial': 'ma' // For word completion hint
    },
    {
      'word': 'kɛnɛya',
      'options': ['gɛlɛya', 'kɛlɛ', 'kɛnɛya'],
      'image': 'assets/nkalanIm/sante.jpg',
      'audio': 'nkalanSound/sante.mp3',
      'hint': 'daamu don.',
      'partial': 'kɛn' // For word completion hint
    },
    // Add more unique words with hints and partial spellings...
  ];

  int currentIndex = 0;
  String? selectedOption;
  bool _showCelebration = false;
  bool _isCorrect = false;
  bool _showHint = false;
  bool _showWordCompletion = false;
  final TextEditingController _wordController = TextEditingController();

  void checkAnswer(String option) async {
    setState(() {
      selectedOption = option;
      _isCorrect = option == spells[currentIndex]['word'];
    });

    if (_isCorrect) {
      _confettiController.play();
      _playAudio(spells[currentIndex]['audio']);
      await Future.delayed(1.seconds);
    } else {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
    }
  }

  void _nextWord() {
    if (currentIndex < spells.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
        _isCorrect = false;
        _showHint = false;
        _showWordCompletion = false;
        _wordController.clear();
      });
    } else {
      setState(() => _showCelebration = true);
    }
  }

  void _checkTypedAnswer() {
    if (_wordController.text.toUpperCase() == spells[currentIndex]['word']) {
      setState(() {
        selectedOption = _wordController.text.toUpperCase();
        _isCorrect = true;
      });
      _confettiController.play();
      _playAudio(spells[currentIndex]['audio']);
    } else {
      _audioPlayer.play(AssetSource('sounds/error.mp3'));
    }
  }

  Widget _buildOption(String option) {
    final isSelected = selectedOption == option;
    final isCorrectOption = option == spells[currentIndex]['word'];

    return GestureDetector(
      onTap: () => checkAnswer(option),
      child: AnimatedContainer(
        duration: 300.ms,
        decoration: BoxDecoration(
          color: isSelected
              ? (isCorrectOption ? Colors.black : Colors.grey[300])
              : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (isSelected)
                Icon(
                  isCorrectOption ? Icons.check : Icons.close,
                  color: isCorrectOption ? Colors.white : Colors.black,
                ),
              const SizedBox(width: 10),
              Text(
                option,
                style: TextStyle(
                  fontSize: 24,
                  color: isSelected && isCorrectOption
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .scaleXY(
            begin: 1,
            end: isSelected ? 1.05 : 1,
            duration: 200.ms,
          )
          .then()
          .shakeX(
            duration: 300.ms,
            hz: 4,
            amount: isSelected && !isCorrectOption ? 1 : 0,
          ),
    );
  }

  Widget _buildCelebration() {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/animations/celebration.json',
                    width: 300, repeat: false),
                const Text(
                  'Spelling Master!',
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.celebration, color: Colors.black),
                  label: const Text('Finish!',
                      style: TextStyle(color: Colors.black)),
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [Colors.black, Colors.grey, Colors.white],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showCelebration) return _buildCelebration();

    final currentSpell = spells[currentIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Spell ${currentIndex + 1}/${spells.length}',
            style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: currentIndex / spells.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(currentSpell['image'], height: 200),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.volume_up, color: Colors.black),
                          onPressed: () => _playAudio(currentSpell['audio']),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.lightbulb, color: Colors.black),
                          onPressed: () =>
                              setState(() => _showHint = !_showHint),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: () => setState(
                              () => _showWordCompletion = !_showWordCompletion),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Possible Answers',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...currentSpell['options'].map((option) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: _buildOption(option),
                        )),
                    if (_showHint)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          currentSpell['hint'],
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18),
                        ),
                      ),
                    if (_showWordCompletion)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            Text(
                              'Start with: ${currentSpell['partial']}',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _wordController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: 'Type the word...',
                                hintStyle: const TextStyle(color: Colors.grey),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.black),
                                  onPressed: _checkTypedAnswer,
                                ),
                              ),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    if (_isCorrect)
                      Column(
                        children: [
                          Lottie.asset('assets/animations/success.json',
                              width: 150, repeat: false),
                          ElevatedButton(
                            onPressed: _nextWord,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _playAudio(String path) {
    _audioPlayer.play(AssetSource(path));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    _wordController.dispose();
    super.dispose();
  }
}

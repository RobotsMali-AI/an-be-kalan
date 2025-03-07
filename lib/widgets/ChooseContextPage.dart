// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:lottie/lottie.dart';
// import 'package:confetti/confetti.dart';

// class ChooseContextPage extends StatefulWidget {
//   const ChooseContextPage({super.key});

//   @override
//   State<ChooseContextPage> createState() => _ChooseContextPageState();
// }

// class _ChooseContextPageState extends State<ChooseContextPage> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final ConfettiController _confettiController =
//       ConfettiController(duration: 2.seconds);
//   final List<Map<String, dynamic>> contexts = [
//     {
//       'word': 'CHICKEN',
//       'images': [
//         {'path': 'assets/chicken.jpg', 'correct': true},
//         {'path': 'assets/dog.jpg', 'correct': false},
//         {'path': 'assets/cat.jpg', 'correct': false},
//         {'path': 'assets/cat.jpg', 'correct': false},
//       ],
//       'audio': 'sounds/chicken.mp3',
//     },
//     {
//       'word': 'CHICKEN',
//       'images': [
//         {'path': 'assets/chicken.jpg', 'correct': true},
//         {'path': 'assets/dog.jpg', 'correct': false},
//         {'path': 'assets/cat.jpg', 'correct': false},
//         {'path': 'assets/cat.jpg', 'correct': false},
//       ],
//       'audio': 'sounds/chicken.mp3',
//     },
//     {
//       'word': 'CHICKEN',
//       'images': [
//         {'path': 'assets/chicken.jpg', 'correct': true},
//         {'path': 'assets/dog.jpg', 'correct': false},
//         {'path': 'assets/cat.jpg', 'correct': false},
//         {'path': 'assets/cat.jpg', 'correct': false},
//       ],
//       'audio': 'sounds/chicken.mp3',
//     },
//     {
//       'word': 'CHICKEN',
//       'images': [
//         {'path': 'assets/chicken.jpg', 'correct': true},
//         {'path': 'assets/dog.jpg', 'correct': false},
//         {'path': 'assets/cat.jpg', 'correct': false},
//         {'path': 'assets/cat.jpg', 'correct': false},
//       ],
//       'audio': 'sounds/chicken.mp3',
//     },
//     // Add more words...
//   ];

//   int currentIndex = 0;
//   String? selectedImage;
//   bool _showCelebration = false;
//   bool _isCorrect = false;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _preloadImages();
//   }

//   void _preloadImages() {
//     for (var context in contexts) {
//       for (var image in context['images']) {
//         precacheImage(AssetImage(image['path']), this.context);
//       }
//     }
//   }

//   void checkAnswer(String imagePath) async {
//     final isCorrect = contexts[currentIndex]['images']
//         .firstWhere((img) => img['path'] == imagePath)['correct'];

//     setState(() {
//       selectedImage = imagePath;
//       _isCorrect = isCorrect;
//     });

//     if (isCorrect) {
//       _confettiController.play();
//       await _playAudio(contexts[currentIndex]['audio']);
//       await 1.seconds;

//       if (currentIndex < contexts.length - 1) {
//         setState(() {
//           currentIndex++;
//           selectedImage = null;
//           _isCorrect = false;
//         });
//       } else {
//         setState(() => _showCelebration = true);
//       }
//     } else {
//       await _audioPlayer.play(AssetSource('sounds/error.mp3'));
//       setState(() => _isCorrect = false);
//     }
//   }

//   Widget _buildCelebration() {
//     return Stack(
//       children: [
//         Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blue, Colors.lightBlueAccent],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Lottie.asset('assets/animations/celebration.json',
//                     width: 300, repeat: false),
//                 const Text('Great Job!',
//                     style: TextStyle(
//                         fontSize: 32,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 20),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.celebration, color: Colors.white),
//                   label: const Text('Finish!',
//                       style: TextStyle(color: Colors.white)),
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.amber,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 30, vertical: 15),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Align(
//           alignment: Alignment.topCenter,
//           child: ConfettiWidget(
//             confettiController: _confettiController,
//             blastDirectionality: BlastDirectionality.explosive,
//             colors: const [
//               Colors.green,
//               Colors.blue,
//               Colors.pink,
//               Colors.orange
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_showCelebration) return _buildCelebration();

//     final currentContext = contexts[currentIndex];
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         title: Text('Round ${currentIndex + 1}/${contexts.length}',
//             style: const TextStyle(color: Colors.white)),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.white, Colors.white])),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               // LinearProgressIndicator(
//               //   value: (currentIndex + 1) / contexts.length,
//               //   backgroundColor: Colors.white.withOpacity(0.3),
//               //   color: Colors.green,
//               // ),
//               // const SizedBox(height: 30),
//               Text(currentContext['word'],
//                   style: const TextStyle(
//                       fontSize: 32,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold)),
//               const SizedBox(height: 20),
//               IconButton(
//                 icon:
//                     const Icon(Icons.volume_up, color: Colors.black, size: 40),
//                 onPressed: () => _playAudio(currentContext['audio']),
//               ),
//               const SizedBox(height: 30),
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   childAspectRatio: 1,
//                   mainAxisSpacing: 20,
//                   crossAxisSpacing: 20,
//                   children: currentContext['images'].map<Widget>((img) {
//                     final isSelected = selectedImage == img['path'];
//                     return AnimatedContainer(
//                         duration: 300.ms,
//                         curve: Curves.easeOutBack,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: isSelected
//                                 ? (img['correct'] ? Colors.green : Colors.red)
//                                 : Colors.transparent,
//                             width: 4,
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.2),
//                               blurRadius: 10,
//                               spreadRadius: 2,
//                             )
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(16),
//                           child: Stack(
//                             children: [
//                               Image.asset(img['path'], fit: BoxFit.cover),
//                               if (isSelected)
//                                 Positioned.fill(
//                                   child: Container(
//                                     color: Colors.black.withOpacity(0.4),
//                                     child: Center(
//                                       child: Icon(
//                                         img['correct']
//                                             ? Icons.check_circle
//                                             : Icons.cancel,
//                                         color: Colors.white,
//                                         size: 60,
//                                       ).animate().scale(),
//                                     ),
//                                   ),
//                                 ),
//                               Positioned.fill(
//                                 child: Material(
//                                   color: Colors.transparent,
//                                   child: InkWell(
//                                     onTap: () => checkAnswer(img['path']),
//                                     splashColor: Colors.white.withOpacity(0.2),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                             .animate(
//                                 delay: 100.ms *
//                                     currentContext['images'].indexOf(img))
//                             .slideY(begin: 1, curve: Curves.easeOutBack)
//                             .fadeIn());
//                     ;
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _playAudio(String path) async {
//     await _audioPlayer.play(AssetSource(path));
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     _confettiController.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';

class ChooseContextPage extends StatefulWidget {
  const ChooseContextPage({super.key});

  @override
  State<ChooseContextPage> createState() => _ChooseContextPageState();
}

class _ChooseContextPageState extends State<ChooseContextPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfettiController _confettiController =
      ConfettiController(duration: 2.seconds);
  final List<Map<String, dynamic>> contexts = [
    {
      'word': 'Fali',
      'images': [
        {'path': 'assets/nkalanIm/ane.jpg', 'correct': true},
        {'path': 'assets/nkalanIm/ble.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/arbre.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/baton.jpg', 'correct': false},
      ],
      'audio': 'nkalanSound/ane.mp3',
    },
    {
      'word': 'Kalan',
      'images': [
        {'path': 'assets/nkalanIm/bouche.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/beaucoup.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/arbre.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/apprentissage.jpg', 'correct': true},
      ],
      'audio': 'nkalanSound/apprentissage.mp3',
    },
    {
      'word': 'muru',
      'images': [
        {'path': 'assets/nkalanIm/lunette.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/couteau.jpg', 'correct': true},
        {'path': 'assets/nkalanIm/citron.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/daba.jpg', 'correct': false},
      ],
      'audio': 'nkalanSound/couteau.mp3',
    },
    {
      'word': 'enfant',
      'images': [
        {'path': 'assets/nkalanIm/enfant.jpg', 'correct': true},
        {'path': 'assets/nkalanIm/dos.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/ecouteur.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/diable.jpg', 'correct': false},
      ],
      'audio': 'nkalanSound/enfant.mp3',
    },
    {
      'word': 'kalanso',
      'images': [
        {'path': 'assets/nkalanIm/eau.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/ecole.jpg', 'correct': true},
        {'path': 'assets/nkalanIm/entrainement.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/famille.jpg', 'correct': false},
      ],
      'audio': 'nkalanSound/ecole.mp3',
    },
    {
      'word': 'muso',
      'images': [
        {'path': 'assets/nkalanIm/facon.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/eleve.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/femme.jpg', 'correct': true},
        {'path': 'assets/nkalanIm/homme.jpg', 'correct': false},
      ],
      'audio': 'nkalanSound/femme.mp3',
    },
    {
      'word': 'fatɔ',
      'images': [
        {'path': 'assets/nkalanIm/exemple.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/fou.jpg', 'correct': true},
        {'path': 'assets/nkalanIm/fevrier.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/eleve.jpg', 'correct': false},
      ],
      'audio': 'nkalanSound/fou.mp3',
    },
    {
      'word': 'fatɔ',
      'images': [
        {'path': 'assets/nkalanIm/exemple.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/fou.jpg', 'correct': true},
        {'path': 'assets/nkalanIm/fevrier.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/eleve.jpg', 'correct': false},
      ],
      'audio': 'nkalanSound/fou.mp3',
    },
    {
      'word': 'cɛmisɛn',
      'images': [
        {'path': 'assets/nkalanIm/griot.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/fou.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/foule.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/garcon.jpg', 'correct': true},
      ],
      'audio': 'nkalanSound/garcon.mp3',
    },
    {
      'word': 'jɛkɛ',
      'images': [
        {'path': 'assets/nkalanIm/foie.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/poisson.jpg', 'correct': true},
        {'path': 'assets/nkalanIm/foule.jpg', 'correct': false},
        {'path': 'assets/nkalanIm/oiseau.jpg', 'correct': false},
      ],
      'audio': 'nkalanSound/poisson.mp3',
    },

    // Add more contexts with different words and images in the actual app
  ];

  int currentIndex = 0;
  String? selectedImage;
  bool _showCelebration = false;
  bool _isCorrect = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  }

  void _preloadImages() {
    for (var context in contexts) {
      for (var image in context['images']) {
        precacheImage(AssetImage(image['path']), this.context);
      }
    }
  }

  void checkAnswer(String imagePath) async {
    final isCorrect = contexts[currentIndex]['images']
        .firstWhere((img) => img['path'] == imagePath)['correct'];

    setState(() {
      selectedImage = imagePath;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _confettiController.play();
      await _playAudio(contexts[currentIndex]['audio']);
      await Future.delayed(
          1.seconds); // Assuming an extension for int.seconds exists

      if (currentIndex < contexts.length - 1) {
        setState(() {
          currentIndex++;
          selectedImage = null;
          _isCorrect = false;
        });
      } else {
        setState(() => _showCelebration = true);
      }
    } else {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
      setState(() => _isCorrect = false);
    }
  }

  Widget _buildCelebration() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey, Colors.grey], // Grayscale gradient
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/animations/celebration.json',
                    width: 300, repeat: false),
                const Text(
                  'Great Job!',
                  style: TextStyle(
                    fontSize: 32,
                    color:
                        Colors.black, // Black text for contrast on light gray
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.celebration, color: Colors.white),
                  label: const Text('Finish!',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
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
            colors: const [
              Colors.black,
              Colors.grey,
              Colors.black,
              Colors.grey,
            ], // Grayscale confetti
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showCelebration) return _buildCelebration();

    final currentContext = contexts[currentIndex];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Round ${currentIndex + 1}/${contexts.length}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (currentIndex + 1) / contexts.length,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              ),
              const SizedBox(height: 30),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, color: Colors.black),
                  SizedBox(width: 10),
                  Text(
                    'Tap the correct picture for',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _playAudio(currentContext['audio']),
                child: Text(
                  currentContext['word'],
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              IconButton(
                icon:
                    const Icon(Icons.volume_up, color: Colors.black, size: 40),
                onPressed: () => _playAudio(currentContext['audio']),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: currentContext['images'].map<Widget>((img) {
                    final isSelected = selectedImage == img['path'];
                    return AnimatedContainer(
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? (img['correct'] ? Colors.green : Colors.red)
                              : Colors.transparent,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.asset(img['path'], fit: BoxFit.cover),
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(0.4),
                                  child: Center(
                                    child: Icon(
                                      img['correct']
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: Colors.white,
                                      size: 60,
                                    ).animate().scale(),
                                  ),
                                ),
                              ),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => checkAnswer(img['path']),
                                  splashColor: Colors.white.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate(
                            delay:
                                100.ms * currentContext['images'].indexOf(img))
                        .slideY(
                          begin: 1,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn();
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _playAudio(String path) async {
    await _audioPlayer.stop(); // Prevent overlap
    await _audioPlayer.play(AssetSource(path));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}

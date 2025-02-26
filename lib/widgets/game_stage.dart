import 'dart:math';
import 'package:flutter/material.dart';

class GameLevelPage extends StatefulWidget {
  const GameLevelPage({super.key});

  @override
  _GameLevelPageState createState() => _GameLevelPageState();
}

class _GameLevelPageState extends State<GameLevelPage> {
  // List of animal images, shuffled for random placement
  final List<String> imagePaths = [
    'assets/icon/appIcon.png',
    'assets/icon/appIcon.png',
    'assets/icon/appIcon.png',
    'assets/icon/appIcon.png',
  ]..shuffle();

  // Target image for this level
  final String targetImagePath = 'assets/images/hen.jpg';

  // State variables for animation feedback
  int? wrongSelectionIndex;
  bool isCorrectSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header matching story screens
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Baganw - Game Level 1',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Target image with speaker button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(targetImagePath, width: 100, height: 100),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.purple),
                  onPressed: () {
                    // Placeholder for audio playback (e.g., "hen" in the app's language)
                    print('Playing audio for $targetImagePath');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Grid of selectable images
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  Widget imageWidget = Image.asset(imagePaths[index]);

                  // Shake animation for incorrect selection
                  if (wrongSelectionIndex == index) {
                    imageWidget = TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) {
                        double offset =
                            sin(value * 2 * pi * 4) * 5; // 4 shake cycles
                        return Transform.translate(
                          offset: Offset(offset, 0),
                          child: child,
                        );
                      },
                      child: imageWidget,
                    );
                  }

                  // Scale and checkmark for correct selection
                  if (isCorrectSelected &&
                      imagePaths[index] == targetImagePath) {
                    imageWidget = Stack(
                      alignment: Alignment.center,
                      children: [
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 1, end: 1.2),
                          duration: const Duration(seconds: 1),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: imageWidget,
                        ),
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 50),
                      ],
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      if (imagePaths[index] == targetImagePath) {
                        setState(() {
                          isCorrectSelected = true;
                        });
                        Future.delayed(const Duration(seconds: 1), () {
                          // Navigate to next level or back to story
                          print('Correct! Proceeding to next level.');
                          // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => GameLevel2Page()));
                        });
                      } else {
                        setState(() {
                          wrongSelectionIndex = index;
                        });
                        Future.delayed(const Duration(milliseconds: 500), () {
                          setState(() {
                            wrongSelectionIndex = null;
                          });
                        });
                      }
                    },
                    child: imageWidget,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

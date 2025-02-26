import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class BagaguwPage extends StatefulWidget {
  const BagaguwPage({super.key});

  @override
  _BagaguwPageState createState() => _BagaguwPageState();
}

class _BagaguwPageState extends State<BagaguwPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, String> audioPaths = {
    'image_0': 'assets/audio/bagaguw1.mp3',
    'image_1': 'assets/audio/bagaguw2.mp3',
    'image_2': 'assets/audio/bagaguw3.mp3',
    'image_3': 'assets/audio/bagaguw4.mp3',
  };

  void _playAudio(String imageId) async {
    // await _audioPlayer.play(AssetSource(audioPaths[imageId]!.split('assets/')[1]));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  // List of image paths (replace these with your actual asset paths)
  final List<String> imagePaths = [
    'assets/icon/appIcon.png',
    'assets/icon/appIcon.png',
    'assets/icon/appIcon.png',
    'assets/icon/appIcon.png',
  ];

  @override
  void initState() {
    super.initState();
    // Animation controller with 1100ms duration for staggered effect
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    )..forward(); // Start the animation when the page loads
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  // Calculate animation progress for each image based on its index
  double getAnimationValue(int index) {
    double start =
        (index * 200) / 1100; // Start time for each image (200ms apart)
    double end =
        (index * 200 + 500) / 1100; // End time (500ms duration per animation)
    double value = (_controller.value - start) / (end - start);
    return value.clamp(0.0, 1.0); // Clamp between 0 and 1
  }

  // Placeholder function for audio playback
  // void _playAudio(String imageId) {
  //   print('Playing audio for $imageId');
  //   // Replace with actual audio playback logic, e.g., using the audioplayers package
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Subtle gradient background inspired by the app's aesthetic
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.withOpacity(0.1),
              Colors.yellow.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with "Bagaguw" title and close button
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(8), // Margin for better spacing
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bagaguw',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context), // Close the page
                    ),
                  ],
                ),
              ),
              // Main content centered on the screen
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Prominent "Bagaguw" text
                      const Text(
                        'Bagaguw',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                          height: 20), // Spacing between text and grid
                      // 2x2 Grid of images
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.count(
                          shrinkWrap:
                              true, // Prevent GridView from taking full height
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable scrolling
                          crossAxisCount: 2, // 2 columns
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: List.generate(4, (index) {
                            return AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                double animationValue =
                                    getAnimationValue(index);
                                return Opacity(
                                  opacity: animationValue, // Fade-in effect
                                  child: Transform.scale(
                                    scale: animationValue, // Scale-up effect
                                    child: child,
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  // Image with shadow and rounded corners
                                  Material(
                                    elevation: 2, // Subtle shadow for depth
                                    borderRadius: BorderRadius.circular(8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        imagePaths[index],
                                        fit: BoxFit
                                            .cover, // Ensure image fills the space
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                  // Speaker icon for audio playback
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.volume_up,
                                        color: Colors.purple,
                                      ),
                                      onPressed: () =>
                                          _playAudio('image_$index'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
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

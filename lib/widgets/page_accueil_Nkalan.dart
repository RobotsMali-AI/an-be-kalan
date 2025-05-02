import 'package:flutter/material.dart';
import 'package:literacy_app/widgets/ChooseContextPage.dart';
import 'package:literacy_app/widgets/ChooseCorrectSpellPage.dart';
import 'package:literacy_app/widgets/WordsCompletePage.dart';
import 'package:literacy_app/widgets/alphabtPage.dart';
import 'package:literacy_app/widgets/syllabus.dart';

class AcceuilNkalan extends StatelessWidget {
  const AcceuilNkalan({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the list of games with titles, images, and navigation pages
    final List<Map<String, dynamic>> games = [
      {
        'title': 'Daɲɛw dafali',
        'image':
            'assets/imJeu3.jpg', // Replace with actual grayscale image path
        'page': const WordsCompletePage(),
      },
      {
        'title': 'Sɛbɛn cogo ɲuman sugandili',
        'image':
            'assets/imJeu2.jpg', // Replace with actual grayscale image path
        'page': const ChooseCorrectSpellPage(),
      },
      {
        'title': 'Ja ɲuman sukandili',
        'image':
            'assets/imJeu1.jpg', // Replace with actual grayscale image path
        'page': const ChooseContextPage(),
      },
      {
        'title': 'Kalan',
        'image':
            'assets/imJeu1.jpg', // Replace with actual grayscale image path
        'page': const AlphabetPage(),
      },
      // {
      //   'title': 'Kalan',
      //   'image':
      //       'assets/imJeu1.jpg', // Replace with actual grayscale image path
      //   'page': SyllableSoundsScreen(),
      // },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Center(
          child: Text(
            'Nkalan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => game['page']),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  game['image'],
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            game['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:literacy_app/widgets/ChooseContextPage.dart';
import 'package:literacy_app/widgets/ChooseCorrectSpellPage.dart';
import 'package:literacy_app/widgets/WordsCompletePage.dart';

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
        'title': 'sɛbɛn coko ɲuma sukandili',
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
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Center(
          child: Text(
            'Nkalan',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            childAspectRatio: 0.8, // Taller cards (height > width)
            crossAxisSpacing: 16, // Horizontal spacing between cards
            mainAxisSpacing: 16, // Vertical spacing between cards
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return Card(
              color: Colors.white,
              elevation: 4, // Shadow for depth
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Rounded corners
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
                        child: Image.asset(
                          game['image'],
                          fit: BoxFit.cover, // Ensure image fills the space
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
            );
          },
        ),
      ),
    );
  }
}

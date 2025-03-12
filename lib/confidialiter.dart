import 'package:flutter/material.dart';
import 'package:literacy_app/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Politique de Confidentialité",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Politique de Confidentialité",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Dernière mise à jour : 9/03/2025",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Text(
              "Bienvenue dans notre application d’apprentissage du bambara. Nous attachons une grande importance à la protection de votre vie privée et souhaitons vous informer de la manière dont nous traitons vos données.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("1. Collecte et utilisation des données"),
            _buildSectionContent(
              "• Nous ne collectons aucune donnée personnelle sans votre consentement.\n"
              "• L’application n’enregistre pas votre voix.\n"
              "• Nous collectons uniquement des données liées à la lecture afin d’améliorer l’expérience utilisateur.\n"
              "• Certaines données anonymes peuvent être conservées à des fins d’analyse et d’amélioration de l’application.",
            ),
            _buildSectionTitle("2. Suppression des données"),
            _buildSectionContent(
              "• Si vous supprimez votre compte, toutes les données personnelles associées seront supprimées.\n"
              "• Les données anonymes collectées à des fins statistiques peuvent être conservées.",
            ),
            _buildSectionTitle("3. Sécurité des données"),
            _buildSectionContent(
              "Nous mettons en place des mesures de sécurité pour protéger les données collectées et éviter tout accès non autorisé.",
            ),
            _buildSectionTitle("4. Affichage de cette politique"),
            _buildSectionContent(
              "Cette politique de confidentialité sera affichée lors du premier lancement de l’application.",
            ),
            _buildSectionTitle("5. Modifications"),
            _buildSectionContent(
              "Nous nous réservons le droit de modifier cette politique. Toute mise à jour sera indiquée dans l’application ou sur notre site web [RobotsMali].",
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('hasSeenConfidialiter', true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AuthGate()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  "J'ai compris",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

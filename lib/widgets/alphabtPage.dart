import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:literacy_app/models/alphabet_model.dart';

class AlphabetPage extends StatefulWidget {
  @override
  _AlphabetPageState createState() => _AlphabetPageState();
}

class _AlphabetPageState extends State<AlphabetPage> {
  List<AlphabetItem> alphabetList = [];
  int currentIndex = 0;
  bool isLoading = true;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentIndex);
    loadData();
  }

  Future<void> loadData() async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/jsons/alphabet.json');
      print(jsonString);
      List<dynamic> jsonData = json.decode(jsonString);
      alphabetList =
          jsonData.map((item) => AlphabetItem.fromJson(item)).toList();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // Handle potential errors (e.g., JSON file not found)
      print('Error loading JSON: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Learn the Alphabet'),
          backgroundColor: Colors.teal,
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: alphabetList.length,
                itemBuilder: (context, index) {
                  AlphabetItem item = alphabetList[index];
                  return Column(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Container(
                          margin: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                            image: DecorationImage(
                              image: AssetImage(item.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.letter.toUpperCase(),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              item.word,
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(height: 16),
                            IconButton(
                              icon: Icon(Icons.volume_up,
                                  size: 32, color: Colors.teal),
                              onPressed: () async {
                                final player = AudioPlayer();
                                await player.play(AssetSource(item.audio));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: currentIndex > 0
                        ? () {
                            pageController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        : null,
                    child: Text('Précédent', style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: currentIndex < alphabetList.length - 1
                        ? () {
                            pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        : null,
                    child: Text('Suivant', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

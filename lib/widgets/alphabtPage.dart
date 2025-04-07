// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:literacy_app/models/alphabet_model.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AlphabetPage extends StatefulWidget {
//   @override
//   _AlphabetPageState createState() => _AlphabetPageState();
// }

// class _AlphabetPageState extends State<AlphabetPage> {
//   List<AlphabetItem> alphabetList = [];
//   int currentIndex = 0;
//   bool isLoading = true;
//   late PageController pageController;

//   @override
//   void initState() {
//     super.initState();
//     pageController = PageController(initialPage: currentIndex);
//     loadData();
//   }

//   Future<void> loadData() async {
//     try {
//       String jsonString =
//           await rootBundle.loadString('assets/jsons/alphabet.json');
//       print(jsonString);
//       List<dynamic> jsonData = json.decode(jsonString);
//       alphabetList =
//           jsonData.map((item) => AlphabetItem.fromJson(item)).toList();
//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       // Handle potential errors (e.g., JSON file not found)
//       print('Error loading JSON: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     } else {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Learn the Alphabet'),
//           backgroundColor: Colors.teal,
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: PageView.builder(
//                 controller: pageController,
//                 itemCount: alphabetList.length,
//                 itemBuilder: (context, index) {
//                   AlphabetItem item = alphabetList[index];
//                   return Column(
//                     children: [
//                       Expanded(
//                         flex: 4,
//                         child: Container(
//                           margin: const EdgeInsets.all(16.0),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.5),
//                                 spreadRadius: 5,
//                                 blurRadius: 7,
//                                 offset: const Offset(0, 3),
//                               ),
//                             ],
//                             image: DecorationImage(
//                               image: AssetImage(item.image),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 2,
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               item.letter,
//                               style: const TextStyle(
//                                 fontSize: 48,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.teal,
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 const Spacer(),
//                                 Text(
//                                   item.letter,
//                                   style: const TextStyle(
//                                     fontSize: 48,
//                                     fontFamily: 'Caveat VariableFont',
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.teal,
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 Text(
//                                   item.letter.toUpperCase(),
//                                   style: const TextStyle(
//                                     fontSize: 48,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.teal,
//                                   ),
//                                 ),
//                                 Spacer(),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                             IconButton(
//                               icon: const Icon(Icons.volume_up,
//                                   size: 32, color: Colors.teal),
//                               onPressed: () async {
//                                 final player = AudioPlayer();
//                                 await player.play(AssetSource(item.audio));
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//                 onPageChanged: (index) {
//                   setState(() {
//                     currentIndex = index;
//                   });
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.teal,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 10),
//                     ),
//                     onPressed: currentIndex > 0
//                         ? () {
//                             pageController.previousPage(
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.easeIn,
//                             );
//                           }
//                         : null,
//                     child:
//                         const Text('Précédent', style: TextStyle(fontSize: 16)),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.teal,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 10),
//                     ),
//                     onPressed: currentIndex < alphabetList.length - 1
//                         ? () {
//                             pageController.nextPage(
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.easeIn,
//                             );
//                           }
//                         : null,
//                     child:
//                         const Text('Suivant', style: TextStyle(fontSize: 16)),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     pageController.dispose();
//     super.dispose();
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:literacy_app/models/alphabet_model.dart';

// class AlphabetPage extends StatefulWidget {
//   @override
//   _AlphabetPageState createState() => _AlphabetPageState();
// }

// class _AlphabetPageState extends State<AlphabetPage> {
//   List<AlphabetItem> alphabetList = [];
//   int currentIndex = 0;
//   bool isLoading = true;
//   late PageController pageController;

//   @override
//   void initState() {
//     super.initState();
//     pageController = PageController(initialPage: currentIndex);
//     loadData();
//   }

//   Future<void> loadData() async {
//     try {
//       String jsonString =
//           await rootBundle.loadString('assets/jsons/alphabet.json');
//       List<dynamic> jsonData = json.decode(jsonString);
//       alphabetList =
//           jsonData.map((item) => AlphabetItem.fromJson(item)).toList();
//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading JSON: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Learn the Alphabet'),
//         backgroundColor: Colors.teal,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: PageView.builder(
//               controller: pageController,
//               itemCount: alphabetList.length,
//               itemBuilder: (context, index) {
//                 return AlphabetCard(item: alphabetList[index]);
//               },
//               onPageChanged: (index) {
//                 setState(() {
//                   currentIndex = index;
//                 });
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 10),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: currentIndex > 0
//                       ? () {
//                           pageController.previousPage(
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeIn,
//                           );
//                         }
//                       : null,
//                   child: const Icon(Icons.arrow_back, size: 24),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 10),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: currentIndex < alphabetList.length - 1
//                       ? () {
//                           pageController.nextPage(
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeIn,
//                           );
//                         }
//                       : null,
//                   child: const Icon(Icons.arrow_forward, size: 24),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     pageController.dispose();
//     super.dispose();
//   }
// }

// class AlphabetCard extends StatefulWidget {
//   final AlphabetItem item;

//   const AlphabetCard({required this.item});

//   @override
//   _AlphabetCardState createState() => _AlphabetCardState();
// }

// class _AlphabetCardState extends State<AlphabetCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
//     _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
//     );
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           flex: 4,
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: GestureDetector(
//               onTap: () async {
//                 final player = AudioPlayer();
//                 await player.play(AssetSource(widget.item.audio));
//               },
//               child: Stack(
//                 children: [
//                   Container(
//                     margin: const EdgeInsets.all(16.0),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           spreadRadius: 5,
//                           blurRadius: 7,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                       image: DecorationImage(
//                         image: AssetImage(widget.item.image),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 10,
//                     right: 10,
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.teal.withOpacity(0.7),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.volume_up,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           flex: 2,
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.teal.shade50, Colors.white],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.5),
//                     spreadRadius: 5,
//                     blurRadius: 7,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: ScaleTransition(
//                   scale: _scaleAnimation,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         widget.item.letter,
//                         style: TextStyle(
//                           fontSize: 48,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.teal.shade700,
//                           shadows: [
//                             Shadow(
//                               blurRadius: 3.0,
//                               color: Colors.black.withOpacity(0.5),
//                               offset: const Offset(2.0, 2.0),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           const Spacer(),
//                           Text(
//                             widget.item.letter,
//                             style: TextStyle(
//                               fontSize: 48,
//                               fontFamily: 'Caveat VariableFont',
//                               fontWeight: FontWeight.bold,
//                               color: Colors.teal.shade500,
//                               shadows: [
//                                 Shadow(
//                                   blurRadius: 3.0,
//                                   color: Colors.black.withOpacity(0.5),
//                                   offset: const Offset(2.0, 2.0),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const Spacer(),
//                           Text(
//                             widget.item.letter.toUpperCase(),
//                             style: TextStyle(
//                               fontSize: 48,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.teal.shade900,
//                               shadows: [
//                                 Shadow(
//                                   blurRadius: 3.0,
//                                   color: Colors.black.withOpacity(0.5),
//                                   offset: const Offset(2.0, 2.0),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const Spacer(),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
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
    // Initialize PageController with viewportFraction set to 1.0
    pageController = PageController(
      initialPage: currentIndex,
      viewportFraction: 1.0, // Each page fills the entire screen width
    );
    loadData();
  }

  Future<void> loadData() async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/jsons/alphabet.json');
      List<dynamic> jsonData = json.decode(jsonString);
      alphabetList =
          jsonData.map((item) => AlphabetItem.fromJson(item)).toList();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading JSON: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn the Alphabet'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: alphabetList.length,
              // Disable swipe gestures
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return AlphabetCard(item: alphabetList[index]);
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
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: currentIndex > 0
                      ? () {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      : null,
                  child: const Icon(Icons.arrow_back, size: 24),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: currentIndex < alphabetList.length - 1
                      ? () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      : null,
                  child: const Icon(Icons.arrow_forward, size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class AlphabetCard extends StatefulWidget {
  final AlphabetItem item;

  const AlphabetCard({required this.item});

  @override
  _AlphabetCardState createState() => _AlphabetCardState();
}

class _AlphabetCardState extends State<AlphabetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () async {
                final player = AudioPlayer();
                await player.play(AssetSource(widget.item.audio));
              },
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage(widget.item.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volume_up,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.item.letter,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      Container(
                        height: 10,
                        color: Colors.teal.shade200,
                        width: MediaQuery.of(context).size.width * 0.8,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          Text(
                            widget.item.letter,
                            style: TextStyle(
                              fontSize: 48,
                              fontFamily: 'Caveat VariableFont',
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            widget.item.letter.toUpperCase(),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

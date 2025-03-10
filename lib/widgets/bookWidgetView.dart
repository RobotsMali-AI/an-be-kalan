// import 'package:flutter/material.dart';
// import 'package:literacy_app/backend_code/api_firebase_service.dart';
// import 'package:literacy_app/models/Users.dart';
// import 'package:literacy_app/models/book.dart';
// import 'package:literacy_app/models/bookUser.dart';
// import 'package:provider/provider.dart';

// class BookWidgetView extends StatelessWidget {
//   const BookWidgetView({
//     super.key,
//     required this.book,
//     required this.isCompleted,
//     required this.isInProgress,
//     required this.isDownloaded,
//     required this.user,
//     this.bookUser,
//   });
//   final Users user;
//   final Book book;
//   final bool isCompleted;
//   final bool isInProgress;
//   final bool isDownloaded;
//   final BookUser? bookUser;

//   @override
//   Widget build(BuildContext context) {
//     // Calculate progress as a percentage
//     double progress = 0;
//     if (bookUser != null && bookUser!.totalPages > 0) {
//       final totalPage = bookUser!.totalPages;
//       final bookmarkMatch = RegExp(r'\d+').firstMatch(bookUser!.bookmark);
//       final currentPage = bookmarkMatch != null
//           ? int.tryParse(bookmarkMatch.group(0)!) ?? 0
//           : 0;
//       progress = currentPage / totalPage;
//     }

//     return Stack(
//       children: [
//         // Book Cover with Loading Indicator
//         FutureBuilder(
//           future: precacheImage(NetworkImage(book.cover), context),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               // Show a loading spinner while the image is loading
//               return Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: Colors.grey[300],
//                 ),
//                 child: const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               );
//             } else if (snapshot.hasError) {
//               // Show an error icon if the image fails to load
//               return Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: Colors.grey[300],
//                 ),
//                 child: const Center(
//                   child: Icon(
//                     Icons.error,
//                     color: Colors.red,
//                     size: 40,
//                   ),
//                 ),
//               );
//             } else {
//               // Show the actual image once it's loaded
//               return Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.black,
//                       blurRadius: 6,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                   image: DecorationImage(
//                     image: NetworkImage(book.cover),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               );
//             }
//           },
//         ),
//         // Status and Progress Overlay
//         Container(
//           height: 150,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(6),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Status Labels
//                     Row(
//                       children: [
//                         if (isCompleted)
//                           const StatusLabel(text: "Finis", color: Colors.green),
//                         if (isInProgress)
//                           const StatusLabel(
//                               text: "Encours", color: Colors.orange),
//                         if (!isCompleted && !isInProgress)
//                           const StatusLabel(
//                               text: "Non commencer", color: Colors.blueGrey),
//                       ],
//                     ),
//                     // Progress Bar
//                     if (isInProgress)
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(left: 8),
//                           child: LinearProgressIndicator(
//                             value: progress,
//                             backgroundColor: Colors.grey[300],
//                             color: Colors.green,
//                             minHeight: 6,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               // Download Button
//               // if (!isDownloaded)
//               //   Padding(
//               //     padding: const EdgeInsets.all(6),
//               //     child: IconButton(
//               //       onPressed: () {
//               //         // Handle download logic
//               //         context
//               //             .read<ApiFirebaseService>()
//               //             .addBookToSembest(book, user);
//               //       },
//               //       icon: const Icon(Icons.download),
//               //       style: ElevatedButton.styleFrom(
//               //         foregroundColor: Colors.blue, // Button color
//               //         backgroundColor: Colors.white, // Text color
//               //       ),
//               //     ),
//               //   ),
//             ],
//           ),
//         ),
//         // Book Title
//         Positioned(
//           bottom: 8,
//           left: 8,
//           right: 8,
//           child: Text(
//             book.title,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//               shadows: [
//                 Shadow(color: Colors.black, blurRadius: 4),
//               ],
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class StatusLabel extends StatelessWidget {
//   const StatusLabel({
//     super.key,
//     required this.text,
//     required this.color,
//   });

//   final String text;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 10,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';

class BookWidgetView extends StatelessWidget {
  const BookWidgetView({
    super.key,
    required this.book,
    required this.isCompleted,
    required this.isInProgress,
    required this.isDownloaded,
    required this.user,
    this.bookUser,
  });
  final Users user;
  final Book book;
  final bool isCompleted;
  final bool isInProgress;
  final bool isDownloaded;
  final BookUser? bookUser;

  @override
  Widget build(BuildContext context) {
    // Calculate progress as a percentage
    double progress = 0;
    if (bookUser != null && bookUser!.totalPages > 0) {
      final totalPage = bookUser!.totalPages;
      final bookmarkMatch = RegExp(r'\d+').firstMatch(bookUser!.bookmark);
      final currentPage = bookmarkMatch != null
          ? int.tryParse(bookmarkMatch.group(0)!) ?? 0
          : 0;
      progress = currentPage / totalPage;
    }

    return Stack(
      children: [
        // Book Cover with Loading Indicator
        FutureBuilder(
          future: precacheImage(NetworkImage(book.cover), context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              return Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              );
            } else {
              return Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(book.cover),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }
          },
        ),
        // Status and Progress Overlay
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (isCompleted)
                          const StatusLabel(
                              text: "A bana", color: Colors.green),
                        if (isInProgress)
                          const StatusLabel(
                              text: "A bɛ sen na", color: Colors.orange),
                        if (!isCompleted && !isInProgress)
                          const StatusLabel(
                              text: "A ma daminɛ folo", color: Colors.blueGrey),
                      ],
                    ),
                    if (isInProgress)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            color: Colors.green,
                            minHeight: 6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Download Button (commented out as in original)
              // if (!isDownloaded)
              //   Padding(
              //     padding: const EdgeInsets.all(6),
              //     child: IconButton(
              //       onPressed: () {
              //         context
              //             .read<ApiFirebaseService>()
              //             .addBookToSembest(book, user);
              //       },
              //       icon: const Icon(Icons.download),
              //       style: ElevatedButton.styleFrom(
              //         foregroundColor: Colors.blue,
              //         backgroundColor: Colors.white,
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
        // Updated Book Title with Gradient Background
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  book.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StatusLabel extends StatelessWidget {
  const StatusLabel({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

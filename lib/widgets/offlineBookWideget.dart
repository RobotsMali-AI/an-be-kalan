import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';

class OffBookWidgetView extends StatelessWidget {
  const OffBookWidgetView({
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
      final bookmarkMatch = RegExp(r'\d+').firstMatch(bookUser!.bookmark);
      final currentPage = bookmarkMatch != null
          ? int.tryParse(bookmarkMatch.group(0)!) ?? 0
          : 0;
      progress = currentPage / bookUser!.totalPages;
    }

    final decodedImage = base64Decode(book.cover);

    return Stack(
      children: [
        // Book Cover
        FutureBuilder(
          future: precacheImage(MemoryImage(decodedImage), context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading spinner while the image is loading
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
              // Show an error icon if the image fails to load
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
              // Show the actual image once it's loaded
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
                    image: MemoryImage(decodedImage),
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
                    // Status Labels
                    Row(
                      children: [
                        if (isCompleted)
                          const StatusLabel(text: "Fini", color: Colors.green),
                        if (isInProgress)
                          const StatusLabel(
                              text: "En cours", color: Colors.orange),
                        if (!isCompleted && !isInProgress)
                          const StatusLabel(
                              text: "Non commencé", color: Colors.blueGrey),
                      ],
                    ),
                    // Progress Bar (Visible only if in progress)
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
            ],
          ),
        ),
        // Book Title
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Text(
            book.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              shadows: [
                Shadow(color: Colors.black, blurRadius: 4),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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

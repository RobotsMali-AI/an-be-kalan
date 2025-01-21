import 'package:flutter/material.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';

class BookWidgetView extends StatelessWidget {
  const BookWidgetView({
    super.key,
    required this.book,
    required this.isCompleted,
    required this.isInProgress,
    required this.isDownloaded,
    this.bookUser,
  });

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

    return Stack(
      children: [
        // Book Cover
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(book.cover),
              fit: BoxFit.cover,
            ),
          ),
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
                          const StatusLabel(text: "Finis", color: Colors.green),
                        if (isInProgress)
                          const StatusLabel(
                              text: "Encours", color: Colors.orange),
                        if (!isCompleted && !isInProgress)
                          const StatusLabel(
                              text: "Non commencer", color: Colors.blueGrey),
                      ],
                    ),
                    // Progress Bar
                    if (isInProgress)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            color: Colors.green,
                            minHeight: 6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Download Button
              if (!isDownloaded)
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: IconButton(
                    onPressed: () {
                      // Handle download logic
                      print("Downloading ${book.title}");
                    },
                    icon: const Icon(Icons.download),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue, // Button color
                      backgroundColor: Colors.white, // Text color
                    ),
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

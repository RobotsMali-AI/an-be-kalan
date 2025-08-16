import 'package:fade_shimmer_master/fade_shimmer_master.dart';
import 'package:flutter/material.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:literacy_app/services/translations.dart';

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

    return Card(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Book Cover with loading shimmer
                      Stack(
                        children: [
                          // Shimmer placeholder
                          const FadeShimmerMaster(
                            width: 200,
                            height: 100,
                            useGradient: true,
                            fadeTheme: FadeTheme.light,
                            radius: 8,
                          ),
                          // Book cover image
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.network(
                              book.cover,
                              width: 200,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox
                                    .shrink(); // Show shimmer only
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox
                                    .shrink(); // Show shimmer only
                              },
                            ),
                          ),
                        ],
                      ),

                      // Overlay with Status and Progress
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (isCompleted)
                                  StatusLabel(
                                      text: t(context, 'finished_book'),
                                      color: Colors.green),
                                if (isInProgress)
                                  StatusLabel(
                                      text: t(context, 'in_progress'),
                                      color: Colors.orange),
                                if (!isCompleted && !isInProgress)
                                  StatusLabel(
                                      text: t(context, 'not_biggining_book'),
                                      color: Colors.blueGrey),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isInProgress)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 6,
            ),
          // Status and Progress Overlay
          // Updated Book Title with Gradient Background
          const SizedBox(height: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title.length > 12
                    ? '${book.title.substring(0, 12)}...'
                    : book.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "eGafe",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          )
        ],
      ),
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

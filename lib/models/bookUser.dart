class BookUser {
  String title;
  String bookmark;
  int readingTime;
  List<double> accuracies;

  BookUser({
    required this.title,
    required this.bookmark,
    required this.readingTime,
    required this.accuracies,
  });

  factory BookUser.fromSnapshot(Map<String, dynamic> json) {
    return BookUser(
      title: json['title'] ?? '',
      bookmark: json['bookmark'] ?? 'Page 1',
      readingTime: json['readingTime'] ?? 0,
      accuracies: List<double>.from(
          json['accuracies']?.map((accuracy) => accuracy.toDouble()) ?? []),
    );
  }

  Map<String, dynamic> toSnapshot() {
    return {
      'title': title,
      'bookmark': bookmark,
      'readingTime': readingTime,
      'accuracies': accuracies,
    };
  }
}

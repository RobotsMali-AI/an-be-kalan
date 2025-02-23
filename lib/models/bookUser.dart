class BookUser {
  String title;
  String bookmark;
  int readingTime;
  List<double> accuracies;
  dynamic lastAccessed;
  int totalPages;
  double? creditedXp;
  int? creditedReadingTime;

  BookUser({
    required this.title,
    this.creditedReadingTime,
    this.creditedXp,
    required this.bookmark,
    required this.readingTime,
    required this.accuracies,
    required this.lastAccessed,
    required this.totalPages,
  });

  factory BookUser.fromSnapshot(Map<String, dynamic> data) {
    final date = data['lastAccessed'].runtimeType == String
        ? DateTime.tryParse(data['lastAccessed'])
        : data['lastAccessed'].toDate();
    return BookUser(
      title: data['title'],
      creditedReadingTime: data["creditedReadingTime"] ?? 0,
      creditedXp: data['creditedXp'] ?? 0,
      bookmark: data['bookmark'],
      readingTime: data['readingTime'],
      accuracies: List<double>.from(data['accuracies']),
      lastAccessed: date,
      totalPages: data['totalPages'],
    );
  }

  factory BookUser.fromSemb(Map<String, dynamic> data) {
    String timestamp = data['lastAccessed'].toString();
    return BookUser(
      creditedReadingTime: data["creditedReadingTime"] ?? 0,
      creditedXp: data['creditedXp'] ?? 0,
      title: data['title'],
      bookmark: data['bookmark'],
      readingTime: data['readingTime'],
      accuracies: List<double>.from(data['accuracies']),
      lastAccessed: timestamp,
      totalPages: data['totalPages'],
    );
  }

  Map<String, dynamic> toSnapshot() {
    return {
      "creditedReadingTime": creditedReadingTime,
      'creditedXp': creditedXp,
      'title': title,
      'bookmark': bookmark,
      'readingTime': readingTime,
      'accuracies': accuracies,
      'lastAccessed': lastAccessed,
      'totalPages': totalPages,
    };
  }

  Map<String, dynamic> toSemb() {
    String last = lastAccessed.toString();
    return {
      "creditedReadingTime": creditedReadingTime,
      'creditedXp': creditedXp,
      'title': title,
      'bookmark': bookmark,
      'readingTime': readingTime,
      'accuracies': accuracies,
      'lastAccessed': last,
      'totalPages': totalPages,
    };
  }
}

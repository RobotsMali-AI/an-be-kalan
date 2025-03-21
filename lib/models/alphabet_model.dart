class AlphabetItem {
  final String letter;
  final String word;
  final String image;
  final String audio;

  AlphabetItem({
    required this.letter,
    required this.word,
    required this.image,
    required this.audio,
  });

  factory AlphabetItem.fromJson(Map<String, dynamic> json) {
    return AlphabetItem(
      letter: json['letter'],
      word: json['word'],
      image: json['image'],
      audio: json['audio'],
    );
  }
}

class AlphabetItem {
  final String letter;
  final String audio1;
  final String image;
  final String audio2;

  AlphabetItem({
    required this.letter,
    required this.audio2,
    required this.image,
    required this.audio1,
  });

  factory AlphabetItem.fromJson(Map<String, dynamic> json) {
    return AlphabetItem(
      letter: json['letter'],
      audio1: json['audio1'],
      image: json['image'],
      audio2: json['audio2'],
    );
  }
}

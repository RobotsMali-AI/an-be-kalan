import 'dart:math';

// Computes softmax over each row of a 2D list (logits).
List<List<double>> softmax(List<List<double>> logits) {
  int numRows = logits.length;
  if (numRows == 0) return [];
  int numCols = logits[0].length;
  List<List<double>> result =
      List.generate(numRows, (_) => List.filled(numCols, 0.0));

  for (int i = 0; i < numRows; i++) {
    // Find the maximum value in the current row for numerical stability.
    double maxVal = logits[i][0];
    for (int j = 1; j < numCols; j++) {
      if (logits[i][j] > maxVal) {
        maxVal = logits[i][j];
      }
    }
    // Compute exponentials and their sum.
    List<double> exps = List.filled(numCols, 0.0);
    double sumExp = 0.0;
    for (int j = 0; j < numCols; j++) {
      exps[j] = exp(logits[i][j] - maxVal);
      sumExp += exps[j];
    }
    // Normalize to get probabilities.
    for (int j = 0; j < numCols; j++) {
      result[i][j] = exps[j] / sumExp;
    }
  }
  return result;
}

// Returns a list of pairs [label, index] for each row in 'probs'
// where the maximum probability label is not "blank".
List<List<dynamic>> getLetters(List<List<double>> probs, List<String> labels) {
  List<List<dynamic>> letters = [];
  for (int i = 0; i < probs.length; i++) {
    List<double> row = probs[i];
    // Find the index of the maximum probability in the row.
    int currentCharIdx = 0;
    double maxVal = row[0];
    for (int j = 1; j < row.length; j++) {
      if (row[j] > maxVal) {
        maxVal = row[j];
        currentCharIdx = j;
      }
    }
    // If the label is not "blank", add [label, rowIndex] to the result.
    if (labels[currentCharIdx] != "blank") {
      letters.add([labels[currentCharIdx], i]);
    }
  }
  return letters;
}

final List<String> labels = [
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
  ' ',
  "'",
  '-',
  'ŋ',
  'ɔ',
  'ɛ',
  'ɲ',
  'ɓ',
  'ɾ',
  'blank'
];

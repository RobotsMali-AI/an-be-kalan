// import 'dart:math' as math;

// /// Applies softmax to a 2D list (each row is a logits vector).
// List<List<double>> softmax(List<List<double>> logits) {
//   List<List<double>> result = [];
//   for (var row in logits) {
//     // Compute the maximum value in this row for numerical stability.
//     double maxVal = row.reduce(math.max);
//     // Exponentiate each element after subtracting the row max.
//     List<double> expRow = row.map((x) => math.exp(x - maxVal)).toList();
//     // Sum of exponentials.
//     double sumExp = expRow.reduce((a, b) => a + b);
//     // Divide each exponentiated value by the sum.
//     List<double> softmaxRow = expRow.map((x) => x / sumExp).toList();
//     result.add(softmaxRow);
//   }
//   return result;
// }

// /// Decodes the probabilities into letters by selecting the highest-probability
// /// character at each time step, ignoring any "blank" predictions.
// /// Returns a list of pairs: [predicted letter, time index].
// List<List<dynamic>> getLetters(List<List<double>> probs, List<String> labels) {
//   List<List<dynamic>> letters = [];
//   for (int idx = 0; idx < probs.length; idx++) {
//     List<double> row = probs[idx];
//     // Find index of maximum probability in the row.
//     int maxIndex = 0;
//     double maxVal = row[0];
//     for (int i = 1; i < row.length; i++) {
//       if (row[i] > maxVal) {
//         maxVal = row[i];
//         maxIndex = i;
//       }
//     }
//     // Append letter if it is not "blank".
//     if (labels[maxIndex] != "blank") {
//       letters.add([labels[maxIndex], idx]);
//     }
//   }
//   return letters;
// }

// // Example global label set:
// final List<String> labels = [
//   '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
//   'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
//   'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
//   'w', 'x', 'y', 'z', ' ', "'", '-', 'ŋ', 'ɔ', 'ɛ', 'ɲ', 'ɓ', 'ɾ', 'blank'
// ];

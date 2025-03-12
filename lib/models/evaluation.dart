import 'package:literacy_app/models/oneimagemultiplewordsquestion.dart';
import 'package:literacy_app/models/onewordmultipleimagequestions.dart';
import 'package:literacy_app/models/question.dart';
import 'package:literacy_app/models/trueorfalse.dart';

class Evaluation {
  final List<Question> multiple;
  final List<Trueorfalse> trueorfalse;
  final List<OneImageMultipleWordsQuestion> oneimagemultiplewords;
  final List<OneWordMultipleImagesQuestion> onewordmultipleimages;

  Evaluation({
    required this.multiple,
    required this.trueorfalse,
    required this.oneimagemultiplewords,
    required this.onewordmultipleimages,
  });

  factory Evaluation.fromMap(Map<String, dynamic> data) {
    return Evaluation(
      multiple: (data['multiple'] as List<dynamic>?)
              ?.map((q) => Question.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      trueorfalse: (data['trueorfalse'] as List<dynamic>?)
              ?.map((q) => Trueorfalse.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      oneimagemultiplewords: (data['oneimagemultiplewords'] as List<dynamic>?)
              ?.map((q) => OneImageMultipleWordsQuestion.fromJson(
                  q as Map<String, dynamic>))
              .toList() ??
          [],
      onewordmultipleimages: (data['onewordmultipleimages'] as List<dynamic>?)
              ?.map((q) => OneWordMultipleImagesQuestion.fromJson(
                  q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

import 'package:literacy_app/models/question.dart';
import 'package:literacy_app/models/trueorfalse.dart';

class Evaluation {
  List<Question> multiple;
  List<Trueorfalse> trueorfalse;
  Evaluation({required this.multiple, required this.trueorfalse});

  factory Evaluation.fromMap(Map<String, dynamic> data) {
    return Evaluation(
      trueorfalse: (data['trueorfalse'] as List)
          .map((q) => Trueorfalse.fromJson(q))
          .toList(),
      multiple: (data['multiple'] as List)
          .map((q) => Question.fromMap(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'multiple': multiple.map((q) => q.toMap()).toList(),
    };
  }
}

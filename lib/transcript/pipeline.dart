// // ---------- Helper functions for matrix operations ----------
// import 'dart:typed_data';

// import 'package:flutter/services.dart';
// import 'package:literacy_app/transcript/convert.dart';
// import 'package:onnxruntime/onnxruntime.dart';

// import 'decode.dart';
// import 'preprocesse.dart';

// List<List<double>> transposeMatrix(List<List<double>> matrix) {
//   int rows = matrix.length;
//   int cols = matrix[0].length;
//   List<List<double>> transposed =
//       List.generate(cols, (_) => List.filled(rows, 0.0));
//   for (int i = 0; i < rows; i++) {
//     for (int j = 0; j < cols; j++) {
//       transposed[j][i] = matrix[i][j];
//     }
//   }
//   return transposed;
// }

// List<double> flattenMatrix(List<List<double>> matrix) {
//   return matrix.expand((row) => row).toList();
// }

// Future<List<List<double>>> runOnnxModelInference(
//     List<List<double>> melSpectrogram, String modelPath) async {
//   // Transpose melSpectrogram.
//   List<List<double>> melT = transposeMatrix(melSpectrogram);
//   int T = melT.length;
//   int nMels = melT[0].length;
//   List<double> inputData = flattenMatrix(melT);
//   final floatInputData = Float32List.fromList(inputData);
//   List<int> inputShape = [1, T, nMels];

//   // Initialize ONNX runtime environment.
//   OrtEnv.instance.init();

//   // Load model bytes from assets.
//   final rawAssetFile = await rootBundle.load(modelPath);
//   final bytes = rawAssetFile.buffer.asUint8List();

//   final sessionOptions = OrtSessionOptions();
//   final session = OrtSession.fromBuffer(bytes, sessionOptions);

//   // Instead of session.getInputs()[0].name, use session.inputNames.
//   final inputName = session.inputNames.first;

//   // Create tensor from inputData.
//   final inputTensor =
//       OrtValueTensor.createTensorWithDataList(floatInputData, inputShape);

//   final runOptions = OrtRunOptions();
//   final outputs = session.run(runOptions, {inputName: inputTensor});

//   // Release input tensor and run options.
//   inputTensor.release();
//   runOptions.release();

//   // Assume output is at outputs[0] and its shape is [1, T, numClasses].
//   print("this outputs shape");
//   print(outputs.first!.value);
//   final outputOrt = outputs.first! as OrtValueTensor;
//   // Use the tensorData property to get a flat list of doubles.
//   final List<double> flatList = (outputOrt.value[0] as List)
//       .expand((e) => e as List)
//       .cast<double>()
//       .toList();

//   // Get the output shape.
//   final outputShape = outputOrt.value![0];
//   // if (outputShape.length != 3 || outputShape[0] != 1) {
//   //   throw Exception('Unexpected output shape: $outputShape');
//   // }
//   int outT = outputShape.length;
//   int numClasses = (outputShape[0] as List).length;

//   // Reshape the flat list into a 2D list [T x numClasses].
//   List<List<double>> logits = [];
//   for (int i = 0; i < outT; i++) {
//     logits.add(flatList.sublist(i * numClasses, (i + 1) * numClasses));
//   }

//   // Release output tensors using a for-in loop.
//   for (var element in outputs) {
//     element?.release();
//   }
//   session.release();
//   OrtEnv.instance.release();

//   return logits;
// }

// transcript() async {
//   // 1. Load raw audio samples from a WAV file.
//   // For example, you could load a WAV file from assets. Here, we assume you have a function loadWavFile() that returns List<double>.
//   // For demonstration purposes, we simulate raw audio as a 1-second sine wave (A4 note).
//   // int sampleRate = 16000;
//   // int numSamples = sampleRate;
//   // List<double> t = List.generate(numSamples, (i) => i / sampleRate);
//   // double frequency = 440.0;
//   // List<double> rawAudio =
//   //     t.map((time) => sin(2 * pi * frequency * time)).toList();

//   // // 2. Preprocess the audio to compute the Mel spectrogram.
//   // AudioToMelSpectrogramPreprocessor preprocessor =
//   //     AudioToMelSpectrogramPreprocessor(sampleRate: sampleRate, nMels: 64);
//   // List<List<double>> melSpectrogram = preprocessor.process(rawAudio);
//   // List<double> rawAudio = await loadWavFile("assets/audio.wav");
//   List<double> rawAudio = await convertWavToDoubleList("assets/audio.wav");

//   // 2. Preprocess the audio to compute the Mel spectrogram.
//   //    This uses the previously implemented AudioToMelSpectrogramPreprocessor.
//   AudioToMelSpectrogramPreprocessor preprocessor =
//       AudioToMelSpectrogramPreprocessor(sampleRate: 16000);
//   List<List<double>> melSpectrogram = preprocessor.process(rawAudio);
//   print(
//       "Mel spectrogram shape: ${melSpectrogram.length} x ${melSpectrogram[0].length}");

//   // 3. Run the ONNX model inference on the Mel spectrogram.
//   // Assume your model is stored as an asset at "assets/models/model.onnx".
//   List<List<double>> logits =
//       await runOnnxModelInference(melSpectrogram, "assets/mymodel.onnx");
//   print("Logits shape: ${logits.length} x ${logits[0].length}");

//   // 4. Apply the softmax function to convert logits to probabilities.
//   List<List<double>> probabilities = softmax(logits);

//   // 5. Decode the probabilities into letters.
//   List<List<dynamic>> decodedLetters = getLetters(probabilities, labels);

//   // 6. Combine the decoded letters to form the final transcription.
//   String transcription = decodedLetters.map((pair) => pair[0] as String).join();
//   print("Transcription: $transcription");
// }

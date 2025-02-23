// import 'dart:io';

// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
// import 'package:flutter/services.dart';
// import 'dart:typed_data';

// class SpeechToText {
// // Utility function to load asset file as string/bytes.
//   Future<String> copyAssetFile(String src, [String? dst]) async {
//     final Directory directory = await getApplicationDocumentsDirectory();
//     if (dst == null) {
//       dst = basename(src);
//     }
//     final target = join(directory.path, dst);
//     bool exists = await new File(target).exists();

//     final data = await rootBundle.load(src);

//     if (!exists || File(target).lengthSync() != data.lengthInBytes) {
//       final List<int> bytes =
//           data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//       await File(target).writeAsBytes(bytes);
//     }

//     return target;
//   }

//   Future<Float32List> copyAssetBytes(String assetPath) async =>
//       (await rootBundle.load(assetPath)).buffer.asFloat32List();

//   Future<sherpa_onnx.OfflineModelConfig> getCTCModelConfig() async {
//     // Change this directory to where you placed your exported CTC model.
//     return sherpa_onnx.OfflineModelConfig(
//         numThreads: 2,
//         modelType: 'ctc',
//         nemoCtc: sherpa_onnx.OfflineNemoEncDecCtcModelConfig(
//             model: await copyAssetFile('assets/model.onnx')),
//         tokens: await copyAssetFile('assets/tokens.txt'));
//   }

//   /// Process a chunk of audio data (as 16-bit PCM).
//   /// Returns the transcript text.
//   Future<String> processAudio() async {
//     Float32List audioChunk = await copyAssetBytes("assets/audio.wav");
//     // The recognizer processes the waveform and returns a result.
//     final _recognizer = sherpa_onnx.OfflineRecognizer(
//         sherpa_onnx.OfflineRecognizerConfig(model: await getCTCModelConfig()));
//     final stream = _recognizer.createStream();
//     stream.acceptWaveform(samples: audioChunk, sampleRate: 16000);
//     // final result = _recognizer.getResult(stream);
//     _recognizer.decode(stream);

//     // Retrieve and print partial result
//     final result = _recognizer.getResult(stream);
//     if (result.text.isNotEmpty) {
//       print('Partial transcription: ${result.text}');
//     }
//     print("result part----------------------------");
//     print(result.text);
//     print(result.emotion);
//     return result.text;
//   }
// // }
// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
// import 'package:flutter/services.dart';
// import 'dart:typed_data';

// class SpeechToText {
//   // Utility function to copy asset file
//   Future<String> copyAssetFile(String src, [String? dst]) async {
//     final Directory directory = await getApplicationDocumentsDirectory();
//     dst ??= basename(src);
//     final target = join(directory.path, dst);
//     bool exists = await File(target).exists();
//     final data = await rootBundle.load(src);

//     if (!exists || File(target).lengthSync() != data.lengthInBytes) {
//       final List<int> bytes =
//           data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//       await File(target).writeAsBytes(bytes);
//     }
//     return target;
//   }

//   String token = """0 0
// 1 1
// 2 2
// 3 3
// 4 4
// 5 5
// 6 6
// 7 7
// 8 8
// 9 9
// a 10
// b 11
// c 12
// d 13
// e 14
// f 15
// g 16
// h 17
// i 18
// j 19
// k 20
// l 21
// m 22
// n 23
// o 24
// p 25
// q 26
// r 27
// s 28
// t 29
// u 30
// v 31
// w 32
// x 33
// y 34
// z 35
//   36
// ' 37
// - 38
// ŋ 39
// ɔ 40
// ɛ 41
// ɲ 42
// ɓ 43
// ɾ 44
// <blk> 45
// """;

//   Future<Float32List> copyAssetBytes(String assetPath) async =>
//       (await rootBundle.load(assetPath)).buffer.asFloat32List();

//   Future<sherpa_onnx.OfflineModelConfig> getCTCModelConfig() async {
//     return sherpa_onnx.OfflineModelConfig(
//       numThreads: 2,
//       modelType: 'ctc',
//       nemoCtc: sherpa_onnx.OfflineNemoEncDecCtcModelConfig(
//         model: await copyAssetFile('assets/model1.onnx'),
//       ),
//       tokens: token,
//     );
//   }

//   /// Process a chunk of audio data and return the transcription text
//   Future<String> processAudio() async {
//     Float32List audioChunk = await copyAssetBytes("assets/audio.wav");

//     final recognizer = sherpa_onnx.OfflineRecognizer(
//       sherpa_onnx.OfflineRecognizerConfig(model: await getCTCModelConfig()),
//     );

//     final stream = recognizer.createStream();

//     // Feed the audio to the recognizer
//     stream.acceptWaveform(samples: audioChunk, sampleRate: 16000);

//     // **OfflineRecognizer only needs one decode call**
//     recognizer.decode(stream);
//     print("--------------------- Before result ------------------------");
//     // Retrieve the transcription result
//     print(stream);
//     final result = recognizer.getResult(stream);

//     if (result.text.isNotEmpty) {
//       print('Transcription: ${result.text}');
//     }
//     print("--------------------- After result ------------------------");
//     return result.text;
//   }
// }

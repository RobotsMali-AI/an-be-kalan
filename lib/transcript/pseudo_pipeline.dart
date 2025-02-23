// Pseudocode: Full Dart ASR Pipeline
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:literacy_app/transcript/decode.dart';
import 'package:literacy_app/transcript/preprocessing.dart';
// import 'package:literacy_app/transcript/preprocessing.dart';
import 'package:onnxruntime/onnxruntime.dart';

void trasncribe() async {
  // 1. Load raw audio samples from a WAV file.
  //    (Assume loadWavFile returns a List<double> with values in [-1, 1])
  List<double> rawAudio = await loadWavFile("assets/audio.wav");

  // 2. Preprocess the audio to compute the Mel spectrogram.
  //    This uses the previously implemented AudioToMelSpectrogramPreprocessor.
  AudioToMelSpectrogramPreprocessor preprocessor =
      AudioToMelSpectrogramPreprocessor(sampleRate: 16000);
  List<List<double>> melSpectrogram = preprocessor.process(rawAudio);

  // 3. Run the ONNX model inference on the Mel spectrogram.
  //    (Assume runOnnxModelInference takes the preprocessed mel spectrogram
  //     and returns a 2D list of logits with shape [timeSteps x numClasses])
  List<List<double>> logits = await runOnnxModelInference(melSpectrogram);
  print(
      "-------------------------- Before softmax ------------------------------------");
  // 4. Apply the softmax function to convert logits to probabilities.
  List<List<double>> probabilities = softmax(logits);
  print(
      "-------------------------- Before letters ------------------------------------");
  // 5. Decode the probabilities into letters using the getLetters function.
  List<List<dynamic>> decodedLetters = getLetters(probabilities, labels);
  print(
      "-------------------------- Before trasncript ------------------------------------");
  // 6. (Optional) Combine the decoded letters to form the final transcription.
  String transcription = decodedLetters.map((pair) => pair[0]).join();
  print("Transcription: $transcription");
}

Future<List<List<double>>> runOnnxModelInference(
    List<List<double>> melSpectrogram) async {
  // Initialize ONNX Runtime environment
  OrtEnv.instance.init();

  // Load the ONNX model from assets
  final sessionOptions = OrtSessionOptions();
  final rawAssetFile = await rootBundle.load('assets/model1.onnx');
  final bytes = rawAssetFile.buffer.asUint8List();
  final session = OrtSession.fromBuffer(bytes, sessionOptions);
  final runOptions = OrtRunOptions();
  print(session);
  // Transpose the mel spectrogram to match the input shape expected by the model
  List<List<double>> transposedMelSpectrogram = List.generate(
    melSpectrogram[0].length,
    (i) => List.generate(melSpectrogram.length, (j) => melSpectrogram[j][i]),
  );

  // Flatten the transposed data and convert to Float32List
  final flatData = transposedMelSpectrogram.expand((e) => e).toList();
  final float32Data = Float32List.fromList(flatData);

  // Define the shape of the input tensor
  final int batchSize = 1;
  final int melBands = transposedMelSpectrogram.length;
  final int timeSteps = transposedMelSpectrogram[0].length;
  final shape = [
    batchSize,
    melBands,
    timeSteps,
  ];

  // Dynamically get the input name from the model
  final inputName = session.inputNames.first;
  print("Input Name: $inputName");

  // Create input tensor for ONNX model
  final inputOrt = OrtValueTensor.createTensorWithDataList(float32Data, shape);
  final inputs = {inputName: inputOrt};

  // Run inference
  final outputs = session.run(runOptions, inputs);

  // Extract and process the output tensor
  final outputTensor = outputs.first as OrtValueTensor;
  final outputData = outputTensor.value;

  // Flatten the output and reshape it to [timeSteps x numClasses]
  final flatOutputData =
      (outputData[0] as List).expand((e) => e as List).cast<double>().toList();

  final timeStepsOut = outputData[0].length;
  final numClasses = (outputData[0][0] as List).length;

  List<List<double>> logits = [];
  for (int t = 0; t < timeStepsOut; t++) {
    List<double> row =
        flatOutputData.sublist(t * numClasses, (t + 1) * numClasses);
    logits.add(row);
  }

  // Release resources
  inputOrt.release();
  runOptions.release();
  sessionOptions.release();
  session.release();
  OrtEnv.instance.release();

  return logits;
}

/// Asynchronously loads a WAV file from [filePath] and returns a List<double>
/// containing the normalized audio samples (values between -1 and 1).
///
/// This function supports PCM 16-bit and 32-bit WAV files.
Future<List<double>> loadWavFile(String filePath) async {
  // Read the file as bytes.

  // final file = File(filePath);
  // final Uint8List bytes = await file.readAsBytes();
  // final ByteData byteData = bytes.buffer.asByteData()
  final ByteData byteData = await rootBundle.load(filePath);
  final Uint8List bytes = byteData.buffer.asUint8List();

  // Parse chunks until we find the "fmt " and "data" chunks.
  int offset = 12;
  int bitsPerSample = 0;
  int dataStart = 0;
  int dataSize = 0;

  while (offset < bytes.length) {
    final String chunkId =
        String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final int chunkSize = byteData.getUint32(offset + 4, Endian.little);

    if (chunkId == "fmt ") {
      // In the fmt chunk, bytes 8-9: audio format (PCM = 1)
      final int audioFormat = byteData.getUint16(offset + 8, Endian.little);
      if (audioFormat != 1) {
        throw FormatException("Only PCM WAV files are supported.");
      }
      // Sample rate is at offset+12 but is not used here.
      bitsPerSample = byteData.getUint16(offset + 22, Endian.little);
    } else if (chunkId == "data") {
      dataSize = chunkSize;
      dataStart = offset + 8;
      break; // We found the data chunk; stop parsing.
    }

    // Move to the next chunk.
    offset += 8 + chunkSize;
  }

  if (dataStart == 0) {
    throw FormatException("Data chunk not found in WAV file.");
  }

  // Calculate the total number of samples (across all channels).
  final int bytesPerSample = bitsPerSample ~/ 8;
  final int totalSamples = dataSize ~/ bytesPerSample;

  // Create a list for the samples.
  final List<double> samples = List<double>.filled(totalSamples, 0.0);

  // For 16-bit PCM, normalize by 32768.
  if (bitsPerSample == 16) {
    for (int i = 0; i < totalSamples; i++) {
      final int sample = byteData.getInt16(dataStart + i * 2, Endian.little);
      samples[i] = sample / 32768.0;
    }
  }
  // For 32-bit PCM, normalize by 2^31.
  else if (bitsPerSample == 32) {
    for (int i = 0; i < totalSamples; i++) {
      final int sample = byteData.getInt32(dataStart + i * 4, Endian.little);
      samples[i] = sample / math.pow(2, 31);
    }
  } else {
    throw FormatException("Unsupported bits per sample: $bitsPerSample");
  }

  return samples;
}

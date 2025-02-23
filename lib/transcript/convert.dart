import 'dart:typed_data';
import 'package:flutter/services.dart';

Future<List<double>> convertWavToDoubleList(String filePath) async {
  // Load the WAV file as ByteData
  final ByteData byteData = await rootBundle.load(filePath);
  final Uint8List bytes = byteData.buffer.asUint8List();

  // Basic WAV header validation
  if (bytes.length < 44 ||
      !_bytesEqual(bytes.sublist(0, 4), [0x52, 0x49, 0x46, 0x46]) || // "RIFF"
      !_bytesEqual(bytes.sublist(8, 12), [0x57, 0x41, 0x56, 0x45])) {
    // "WAVE"
    throw Exception('Invalid WAV file');
  }

  // Find the "data" chunk by searching the byte array
  int dataChunkStart = _findDataChunk(bytes);
  if (dataChunkStart == -1) throw Exception('Data chunk not found');

  // Extract audio parameters from the "fmt " chunk
  final int bitsPerSample = _getBitsPerSample(bytes);
  final int numChannels = _getNumChannels(bytes);
  if (bitsPerSample != 16 || numChannels != 1) {
    throw Exception('Only 16-bit mono WAV files are supported');
  }

  // Extract raw audio data bytes
  final Uint8List audioBytes = _getAudioBytes(bytes, dataChunkStart);

  // Convert to List<double>
  return _convertBytesToDoubleList(audioBytes);
}

// Helper function to compare byte arrays
bool _bytesEqual(Uint8List a, List<int> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// Find the start position of the "data" chunk
int _findDataChunk(Uint8List bytes) {
  for (int i = 12; i < bytes.length - 8; i++) {
    if (bytes[i] == 0x64 && // 'd'
        bytes[i + 1] == 0x61 && // 'a'
        bytes[i + 2] == 0x74 && // 't'
        bytes[i + 3] == 0x61) {
      // 'a'
      return i;
    }
  }
  return -1;
}

int _getBitsPerSample(Uint8List bytes) {
  return bytes[34] | (bytes[35] << 8);
}

int _getNumChannels(Uint8List bytes) {
  return bytes[22] | (bytes[23] << 8);
}

Uint8List _getAudioBytes(Uint8List bytes, int dataChunkStart) {
  final int dataSize = bytes[dataChunkStart + 4] |
      (bytes[dataChunkStart + 5] << 8) |
      (bytes[dataChunkStart + 6] << 16) |
      (bytes[dataChunkStart + 7] << 24);

  final int audioStart = dataChunkStart + 8;
  final int audioEnd = audioStart + dataSize;

  if (audioEnd > bytes.length) throw Exception('Invalid data size');
  return bytes.sublist(audioStart, audioEnd);
}

List<double> _convertBytesToDoubleList(Uint8List audioBytes) {
  final ByteData audioData = ByteData.view(audioBytes.buffer);
  final List<double> samples = [];

  for (int i = 0; i < audioBytes.length ~/ 2; i++) {
    // Read 16-bit little-endian value and normalize to [-1.0, 1.0]
    final int intValue = audioData.getInt16(i * 2, Endian.little);
    samples.add(intValue / 32768.0);
  }

  return samples;
}

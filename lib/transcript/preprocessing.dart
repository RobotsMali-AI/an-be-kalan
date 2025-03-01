import 'dart:ffi';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:fftea/fftea.dart';

// Custom Complex type to replace the one from the old fft package
// class Complex {
//   final double real;
//   final double imaginary;

//   const Complex(this.real, this.imaginary);

//   double abs() => math.sqrt(real * real + imaginary * imaginary);

//   @override
//   String toString() => '($real, ${imaginary}i)';
// }

class Complex {
  final double real;
  final double imaginary;

  const Complex(this.real, this.imaginary);

  double abs() => math.sqrt(real * real + imaginary * imaginary);

  Complex operator +(Complex other) =>
      Complex(real + other.real, imaginary + other.imaginary);

  Complex operator -(Complex other) =>
      Complex(real - other.real, imaginary - other.imaginary);

  Complex operator *(Complex other) => Complex(
      real * other.real - imaginary * other.imaginary,
      real * other.imaginary + imaginary * other.real);

  Complex conjugate() => Complex(real, -imaginary);

  @override
  String toString() => '($real, ${imaginary}i)';
}

/// AudioToMelSpectrogramPreprocessor implements the full preprocessing pipeline:
/// 1. Pre-emphasis (with preemph coefficient 0.97)
/// 2. Framing using a Hann window (window size 0.02 sec, hop 0.01 sec)
/// 3. STFT (FFT size 512)
/// 4. Magnitude power spectrum (power=2.0)
/// 5. Mel filter bank conversion (64 filters, slaney normalization)
/// 6. Log compression (with zero-guarding using add 2^-24)
/// 7. Per-feature normalization (mean/std computed across time for each mel bin)
/// 8. Padding in time to a multiple of 16 frames.
class AudioToMelSpectrogramPreprocessor {
  final int sampleRate;
  final double windowSizeSec;
  final double windowStrideSec;
  final int nWindowSize; // in samples
  final int nWindowStride; // in samples
  final String windowType; // 'hann'
  final double preemph;
  final int nFFT;
  final int nMels;
  final double lowfreq;
  final double highfreq;
  final bool useLog;
  final double logZeroGuardValue;
  final int padTo;

  AudioToMelSpectrogramPreprocessor({
    this.sampleRate = 16000,
    this.windowSizeSec = 0.02,
    this.windowStrideSec = 0.01,
    String? windowType,
    this.preemph = 0.97,
    int? nFFT,
    this.nMels = 64,
    this.lowfreq = 0.0,
    double? highfreq,
    this.useLog = true,
    double? logZeroGuardValue,
    this.padTo = 16,
  })  : nWindowSize = (0.02 * sampleRate).round(),
        nWindowStride = (0.01 * sampleRate).round(),
        windowType = windowType ?? 'hann',
        nFFT = nFFT ?? 512,
        highfreq = highfreq ?? (sampleRate / 2),
        logZeroGuardValue = logZeroGuardValue ?? math.pow(2, -24).toDouble();

  /// Step 1: Pre-emphasis filtering.
  /// y[0] = x[0]
  /// y[t] = x[t] - preemph * x[t-1] for t >= 1
  List<double> preemphasis(List<double> signal) {
    if (signal.isEmpty) return signal;
    List<double> emphasized = List<double>.filled(signal.length, 0.0);
    emphasized[0] = signal[0];
    for (int i = 1; i < signal.length; i++) {
      emphasized[i] = signal[i] - preemph * signal[i - 1];
    }
    return emphasized;
  }

  /// Generate a Hann window of given length.
  List<double> hannWindow(int length) {
    return List<double>.generate(
        length, (n) => 0.5 * (1 - math.cos(2 * math.pi * n / (length - 1))));
  }

  /// Step 2 & 3: Compute STFT.
  /// The signal is framed using [nWindowSize] and [nWindowStride],
  /// each frame is windowed with a Hann window, zero-padded to [nFFT],
  /// and the FFT is computed.
  // List<List<Complex>> stft(List<double> signal) {
  //   int numFrames = ((signal.length - nWindowSize) / nWindowStride).floor() + 1;
  //   List<double> window = hannWindow(nWindowSize);
  //   List<List<Complex>> stftMatrix = [];
  //   for (int i = 0; i < numFrames; i++) {
  //     int start = i * nWindowStride;
  //     // Extract frame and apply window.
  //     List<double> frame = signal.sublist(start, start + nWindowSize).toList();
  //     for (int j = 0; j < frame.length; j++) {
  //       frame[j] *= window[j];
  //     }
  //     // Zero-pad frame to nFFT if needed.
  //     List<double> padded = List<double>.filled(nFFT, 0.0);
  //     for (int j = 0; j < frame.length; j++) {
  //       padded[j] = frame[j];
  //     }
  //     // Compute FFT on the padded frame.
  //     // FFT().Transform returns List<Complex>
  //     // t.ComplexArray().toRealArray();
  //     final fftFrame = FFT(nFFT).realFft(padded);
  //     for (var i in fftFrame) {
  //       final toC = Float32x4.fromFloat64x2(i);

  //       stftMatrix.add([Complex(toC.x.abs(), toC.y.abs())]);
  //     }
  //     final frameComplex = List<Complex>.generate(
  //     (nFFT ~/ 2) + 1,
  //     (k) {
  //       final real = k == 0 ? fftFrame[0] : fftFrame[2 * k - 1];
  //       final imag = k == 0 ? 0.0 : fftFrame[2 * k];
  //       return Complex(real.x, real.y);
  //     }
  //   );

  //     // final big = ComplexArray(fftFrame).toRealArray();
  //     // // ComplexArray.fromRealArray(padded);
  //     // final compt = Complex;
  //     // stftMatrix.add(fftFrame);
  //   }
  //   return stftMatrix;
  // }

  // List<List<Complex>> stft(List<double> signal) {
  //   int numFrames = ((signal.length - nWindowSize) / nWindowStride).floor() + 1;
  //   List<double> window = hannWindow(nWindowSize);
  //   List<List<Complex>> stftMatrix = [];

  //   for (int i = 0; i < numFrames; i++) {
  //     int start = i * nWindowStride;

  //     // Extract frame and apply window function
  //     List<double> frame = signal.sublist(start, start + nWindowSize).toList();
  //     for (int j = 0; j < frame.length; j++) {
  //       frame[j] *= window[j];
  //     }

  //     // Zero-padding the frame
  //     List<double> padded = List<double>.filled(nFFT, 0.0);
  //     for (int j = 0; j < frame.length; j++) {
  //       padded[j] = frame[j];
  //     }

  //     // Compute FFT
  //     final fftFrame = FFT(nFFT).realFft(padded);

  //     // Convert FFT result to Complex representation
  //     List<Complex> frameComplex = List.generate(
  //       (nFFT ~/ 2),
  //       (k) {
  //         var realPart = fftFrame[k * 2 + 1];
  //         var imagPart =
  //             (k * 2 + 1 < fftFrame.length) ? fftFrame[k * 2 + 1] : 0.0;

  //         double real = realPart is Float64x2 ? realPart.x : realPart as double;
  //         double imag = imagPart is Float64x2 ? imagPart.x : imagPart as double;

  //         return Complex(real, imag);
  //       },
  //     );

  //     stftMatrix.add(frameComplex);
  //   }

  //   return stftMatrix;
  // }

  List<List<Complex>> stft(List<double> signal) {
    int numFrames = ((signal.length - nWindowSize) / nWindowStride).floor() + 1;
    List<double> window = hannWindow(nWindowSize);
    List<List<Complex>> stftMatrix = [];

    for (int i = 0; i < numFrames; i++) {
      int start = i * nWindowStride;

      // Extract frame and apply window function
      List<double> frame = signal.sublist(start, start + nWindowSize).toList();
      for (int j = 0; j < frame.length; j++) {
        frame[j] *= window[j];
      }

      // Zero-padding the frame
      List<double> padded = List<double>.filled(nFFT, 0.0);
      for (int j = 0; j < frame.length; j++) {
        padded[j] = frame[j];
      }

      // Compute FFT
      final fftFrame = FFT(nFFT).realFft(padded);

      // Convert FFT result to Complex representation
      List<Complex> frameComplex = [];
      for (int k = 0; k < fftFrame.length / 2; k++) {
        var realPart = fftFrame[k].x;
        var imagPart = fftFrame[k].y;
        frameComplex.add(Complex(realPart, imagPart));
      }

      stftMatrix.add(frameComplex);
    }

    return stftMatrix;
  }

  /// Step 4: Compute the power spectrum (magnitude^2) from the STFT.
  /// Only the first (nFFT/2 + 1) bins are kept.
  // List<List<double>> powerSpectrum(List<List<Complex>> stftMatrix) {
  //   int halfLength = (nFFT ~/ 2) + 1;
  //   List<List<double>> powerSpec = [];
  //   for (var frame in stftMatrix) {
  //     List<double> powerFrame = List<double>.filled(halfLength, 0.0);
  //     for (int i = 0; i < halfLength; i++) {
  //       double mag = frame[i].abs();
  //       powerFrame[i] = math.pow(mag, 2).toDouble();
  //     }
  //     powerSpec.add(powerFrame);
  //   }
  //   return powerSpec;
  // }

  // List<List<double>> powerSpectrum(List<List<Complex>> stftMatrix) {
  //   final halfLength = (nFFT ~/ 2);
  //   return stftMatrix.map((frame) {
  //     return List<double>.generate(halfLength, (i) {
  //       final re = frame[i].real;
  //       final im = frame[i].imaginary;
  //       return re * re + im * im;
  //     });
  //   }).toList();
  // }

  List<List<double>> powerSpectrum(List<List<Complex>> stftMatrix) {
    return stftMatrix.map((frame) {
      return frame.map((complex) {
        double mag = complex.abs();
        return mag * mag;
      }).toList();
    }).toList();
  }

  /// Step 5: Create a Mel filter bank matrix.
  /// Returns a matrix with dimensions [nMels x (nFFT/2+1)].
  List<List<double>> melFilterBank() {
    int nFftBins = (nFFT ~/ 2) + 1;
    // Convert low and high frequencies to mel scale.
    double melLow = hzToMel(lowfreq);
    double melHigh = hzToMel(highfreq);
    // Equally spaced points in the mel scale.
    List<double> melPoints = linspace(melLow, melHigh, nMels + 2);
    // Convert mel points back to Hz.
    List<double> hzPoints = melPoints.map((m) => melToHz(m)).toList();
    // Map Hz values to FFT bin numbers.
    List<int> bin = hzPoints
        .map((hz) => ((hz / (sampleRate / 2)) * (nFftBins - 1)).floor())
        .toList();

    // Create the filter bank.
    List<List<double>> fbank =
        List.generate(nMels, (_) => List<double>.filled(nFftBins, 0.0));
    for (int m = 1; m <= nMels; m++) {
      int fMMinus = bin[m - 1];
      int fM = bin[m];
      int fMPlus = bin[m + 1];
      for (int k = fMMinus; k < fM; k++) {
        fbank[m - 1][k] = (k - fMMinus) / (fM - fMMinus).toDouble();
      }
      for (int k = fM; k < fMPlus; k++) {
        fbank[m - 1][k] = (fMPlus - k) / (fMPlus - fM).toDouble();
      }
    }
    // Slaney-style normalization: each filter is normalized to have unit area.
    for (int i = 0; i < nMels; i++) {
      double sum = 0.0;
      for (int j = 0; j < nFftBins; j++) {
        sum += fbank[i][j];
      }
      if (sum != 0) {
        for (int j = 0; j < nFftBins; j++) {
          fbank[i][j] /= sum;
        }
      }
    }
    return fbank;
  }

  /// Utility: Convert Hz to Mel scale.
  double hzToMel(double hz) {
    return 2595 * math.log(1 + hz / 700) / math.ln10;
  }

  /// Utility: Convert Mel to Hz.
  double melToHz(double mel) {
    return 700 * (math.pow(10, mel / 2595) - 1);
  }

  /// Utility: Generate linearly spaced numbers between start and end.
  List<double> linspace(double start, double end, int num) {
    if (num == 1) return [start];
    double step = (end - start) / (num - 1);
    return List<double>.generate(num, (i) => start + step * i);
  }

  /// Step 6: Apply the mel filter bank to the power spectrum.
  /// The result is a mel spectrogram with dimensions [numFrames x nMels].
  List<List<double>> applyMelFilterBank(
      List<List<double>> powerSpec, List<List<double>> fbank) {
    int numFrames = powerSpec.length;
    int nFftBins = powerSpec[0].length;
    List<List<double>> melSpectrogram =
        List.generate(numFrames, (_) => List<double>.filled(nMels, 0.0));
    for (int t = 0; t < numFrames; t++) {
      for (int m = 0; m < nMels; m++) {
        double sum = 0.0;
        for (int k = 0; k < nFftBins; k++) {
          sum += fbank[m][k] * powerSpec[t][k];
        }
        melSpectrogram[t][m] = sum;
      }
    }
    return melSpectrogram;
  }

  /// Step 7: Log compression.
  /// Applies: log(x + logZeroGuardValue)
  List<List<double>> logCompress(List<List<double>> melSpectrogram) {
    return melSpectrogram
        .map((frame) =>
            frame.map((x) => math.log(x + logZeroGuardValue)).toList())
        .toList();
  }

  /// Step 8: Per-feature normalization.
  /// For each mel bin (feature), compute mean and standard deviation across time,
  /// and normalize each value.
  List<List<double>> perFeatureNormalization(
      List<List<double>> melSpectrogram) {
    int numFrames = melSpectrogram.length;
    int nFeatures = melSpectrogram[0].length;
    List<double> means = List<double>.filled(nFeatures, 0.0);
    List<double> stds = List<double>.filled(nFeatures, 0.0);

    // Compute means.
    for (int m = 0; m < nFeatures; m++) {
      double sum = 0.0;
      for (int t = 0; t < numFrames; t++) {
        sum += melSpectrogram[t][m];
      }
      means[m] = sum / numFrames;
    }

    // Compute standard deviations.
    for (int m = 0; m < nFeatures; m++) {
      double sumSq = 0.0;
      for (int t = 0; t < numFrames; t++) {
        double diff = melSpectrogram[t][m] - means[m];
        sumSq += diff * diff;
      }
      stds[m] = math.sqrt(sumSq / (numFrames - 1)) + 1e-5;
    }

    // Normalize.
    List<List<double>> normMel =
        List.generate(numFrames, (_) => List<double>.filled(nFeatures, 0.0));
    for (int t = 0; t < numFrames; t++) {
      for (int m = 0; m < nFeatures; m++) {
        normMel[t][m] = (melSpectrogram[t][m] - means[m]) / stds[m];
      }
    }
    return normMel;
  }

  /// Step 9: Pad the time dimension (frames) so that the number of frames is
  /// a multiple of [padTo]. Padding is done with zeros.
  List<List<double>> padFrames(List<List<double>> melSpectrogram) {
    int numFrames = melSpectrogram.length;
    int remainder = numFrames % padTo;
    if (remainder == 0) return melSpectrogram;
    int padFramesCount = padTo - remainder;
    List<List<double>> padded = List.from(melSpectrogram);
    for (int i = 0; i < padFramesCount; i++) {
      padded.add(List<double>.filled(melSpectrogram[0].length, 0.0));
    }
    return padded;
  }

  /// The main processing function.
  /// Given a raw audio signal as List<double> (values in [-1,1]),
  /// it returns the normalized, padded mel spectrogram.
  List<List<double>> process(List<double> rawSignal) {
    // 1. Pre-emphasis
    List<double> emphasized = preemphasis(rawSignal);

    // 2 & 3. Compute STFT
    List<List<Complex>> stftMatrix = stft(emphasized);

    // 4. Compute power spectrum
    List<List<double>> powerSpec = powerSpectrum(stftMatrix);

    // 5. Compute Mel filter bank and apply it.
    List<List<double>> fbank = melFilterBank();
    List<List<double>> melSpec = applyMelFilterBank(powerSpec, fbank);

    // 6. Log compression
    if (useLog) {
      melSpec = logCompress(melSpec);
    }

    // 7. Per-feature normalization
    melSpec = perFeatureNormalization(melSpec);

    // 8. Padding
    melSpec = padFrames(melSpec);

    return melSpec;
  }
}

// Example usage:
// Suppose you have a function that reads a WAV file and returns a List<double>
// representing the audio samples. Then you can do:
//
//   List<double> audioSamples = loadWavFile("path/to/file.wav");
//   AudioToMelSpectrogramPreprocessor preproc = AudioToMelSpectrogramPreprocessor();
//   List<List<double>> melSpectrogram = preproc.process(audioSamples);
//
// This [melSpectrogram] is now ready to be fed into your ONNX model.
void main() {
  // Example: generate a dummy sine wave for 1 second.
  int sampleRate = 16000;
  double frequency = 440.0; // A4 note
  int totalSamples = sampleRate;
  List<double> signal = List<double>.generate(
      totalSamples, (i) => math.sin(2 * math.pi * frequency * i / sampleRate));

  AudioToMelSpectrogramPreprocessor preproc =
      AudioToMelSpectrogramPreprocessor(sampleRate: sampleRate);

  List<List<double>> melSpec = preproc.process(signal);

  print(
      "Mel Spectrogram: ${melSpec.length} frames, ${melSpec[0].length} features per frame");
}

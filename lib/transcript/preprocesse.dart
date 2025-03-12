// import 'dart:math';

// /// A simple Complex number class.
// class Complex {
//   double re;
//   double im;
//   Complex(this.re, [this.im = 0.0]);

//   Complex operator +(Complex other) => Complex(re + other.re, im + other.im);
//   Complex operator -(Complex other) => Complex(re - other.re, im - other.im);
//   Complex operator *(Complex other) =>
//       Complex(re * other.re - im * other.im, re * other.im + im * other.re);
//   Complex operator /(double scalar) => Complex(re / scalar, im / scalar);

//   double abs() => sqrt(re * re + im * im);

//   @override
//   String toString() => '($re${im >= 0 ? '+' : ''}$im i)';
// }

// /// Recursive FFT using the Cooley–Tukey algorithm.
// /// Assumes the length of [x] is a power of 2.
// List<Complex> fft(List<Complex> x) {
//   int n = x.length;
//   if (n == 1) return [Complex(x[0].re, x[0].im)];
//   List<Complex> even = [];
//   List<Complex> odd = [];
//   for (int i = 0; i < n; i++) {
//     if (i % 2 == 0) {
//       even.add(x[i]);
//     } else {
//       odd.add(x[i]);
//     }
//   }
//   List<Complex> fftEven = fft(even);
//   List<Complex> fftOdd = fft(odd);
//   List<Complex> combined = List<Complex>.filled(n, Complex(0));
//   for (int k = 0; k < n ~/ 2; k++) {
//     double angle = -2 * pi * k / n;
//     Complex wk = Complex(cos(angle), sin(angle));
//     Complex t = wk * fftOdd[k];
//     combined[k] = fftEven[k] + t;
//     combined[k + n ~/ 2] = fftEven[k] - t;
//   }
//   return combined;
// }

// /// Compute the real FFT (rfft) on [realSignal] zero‐padded to length [nFFT].
// /// Returns the first nFFT/2+1 bins.
// List<Complex> rfft(List<double> realSignal, int nFFT) {
//   List<Complex> x = List.generate(nFFT, (i) {
//     if (i < realSignal.length) return Complex(realSignal[i], 0);
//     return Complex(0, 0);
//   });
//   List<Complex> fullFFT = fft(x);
//   int nFftBins = nFFT ~/ 2 + 1;
//   return fullFFT.sublist(0, nFftBins);
// }

// /// AudioToMelSpectrogramPreprocessor replicates the Python class functionality.
// class AudioToMelSpectrogramPreprocessor {
//   int sampleRate;
//   double windowSizeSec;
//   double windowStrideSec;
//   late int nWindowSize;
//   late int nWindowStride;
//   String windowType;
//   double preemph;
//   int nFFT;
//   int nMels;
//   double lowfreq;
//   double highfreq;
//   bool useLog;
//   double logZeroGuardValue;
//   int padTo;

//   AudioToMelSpectrogramPreprocessor({
//     this.sampleRate = 16000,
//     this.windowSizeSec = 0.02,
//     this.windowStrideSec = 0.01,
//     this.windowType = 'hann',
//     this.preemph = 0.97,
//     this.nFFT = 512,
//     this.nMels = 64,
//     this.lowfreq = 0.0,
//     double? highfreq,
//     this.useLog = true,
//     double? logZeroGuardValue,
//     this.padTo = 16,
//   })  : highfreq = highfreq ?? (sampleRate / 2),
//         logZeroGuardValue = logZeroGuardValue ?? pow(2, -24).toDouble() {
//     nWindowSize = (windowSizeSec * sampleRate).round();
//     nWindowStride = (windowStrideSec * sampleRate).round();
//   }

//   /// Pre-emphasis filtering.
//   List<double> preemphasisFn(List<double> signal) {
//     if (signal.isEmpty) return signal;
//     List<double> emphasized = List<double>.filled(signal.length, 0.0);
//     emphasized[0] = signal[0];
//     for (int i = 1; i < signal.length; i++) {
//       emphasized[i] = signal[i] - preemph * signal[i - 1];
//     }
//     return emphasized;
//   }

//   /// Generate a Hann window of given [length].
//   List<double> hannWindow(int length) {
//     List<double> window = List<double>.filled(length, 0.0);
//     for (int i = 0; i < length; i++) {
//       window[i] = 0.5 * (1 - cos(2 * pi * i / (length - 1)));
//     }
//     return window;
//   }

//   /// Compute the Short-Time Fourier Transform (STFT).
//   /// Splits the [signal] into overlapping frames, multiplies each frame by a Hann window,
//   /// zero-pads to [nFFT], and computes rFFT for each frame.
//   List<List<Complex>> stft(List<double> signal) {
//     int numFrames = ((signal.length - nWindowSize) / nWindowStride).floor() + 1;
//     List<double> window = hannWindow(nWindowSize);
//     List<List<Complex>> stftMatrix = [];
//     for (int i = 0; i < numFrames; i++) {
//       int start = i * nWindowStride;
//       List<double> frame = List<double>.filled(nWindowSize, 0.0);
//       for (int j = 0; j < nWindowSize; j++) {
//         frame[j] = signal[start + j] * window[j];
//       }
//       List<double> padded = List<double>.filled(nFFT, 0.0);
//       for (int j = 0; j < frame.length; j++) {
//         padded[j] = frame[j];
//       }
//       List<Complex> fftFrame = rfft(padded, nFFT);
//       stftMatrix.add(fftFrame);
//     }
//     return stftMatrix;
//   }

//   /// Compute the power spectrum (magnitude squared) of each STFT frame.
//   List<List<double>> powerSpectrum(List<List<Complex>> stftMatrix) {
//     List<List<double>> powerSpec = [];
//     for (var frame in stftMatrix) {
//       List<double> row = [];
//       for (var c in frame) {
//         row.add(c.abs() * c.abs());
//       }
//       powerSpec.add(row);
//     }
//     return powerSpec;
//   }

//   /// Convert frequency in Hz to Mel scale.
//   double hzToMel(double hz) {
//     return 2595 * log(1 + hz / 700) / log(10);
//   }

//   /// Convert Mel scale to frequency in Hz.
//   double melToHz(double mel) {
//     return 700 * (pow(10, mel / 2595) - 1);
//   }

//   /// Generate [num] linearly spaced numbers between [start] and [end].
//   List<double> linspace(double start, double end, int num) {
//     if (num == 1) return [start];
//     double step = (end - start) / (num - 1);
//     return List<double>.generate(num, (i) => start + i * step);
//   }

//   /// Create a Mel filter bank matrix with shape (nMels, nFFT/2+1) using Slaney-style normalization.
//   List<List<double>> melFilterBank() {
//     int nFftBins = nFFT ~/ 2 + 1;
//     double melLow = hzToMel(lowfreq);
//     double melHigh = hzToMel(highfreq);
//     List<double> melPoints = linspace(melLow, melHigh, nMels + 2);
//     List<double> hzPoints = melPoints.map((m) => melToHz(m)).toList();
//     List<int> bins = hzPoints.map((hz) {
//       return ((hz / (sampleRate / 2)) * (nFftBins - 1)).floor();
//     }).toList();
//     List<List<double>> fbank =
//         List.generate(nMels, (_) => List<double>.filled(nFftBins, 0.0));
//     for (int m = 1; m <= nMels; m++) {
//       int fMMinus = bins[m - 1];
//       int fM = bins[m];
//       int fMPlus = bins[m + 1];
//       for (int k = fMMinus; k < fM; k++) {
//         if (fM - fMMinus != 0) {
//           fbank[m - 1][k] = (k - fMMinus) / (fM - fMMinus);
//         }
//       }
//       for (int k = fM; k < fMPlus; k++) {
//         if (fMPlus - fM != 0) {
//           fbank[m - 1][k] = (fMPlus - k) / (fMPlus - fM);
//         }
//       }
//     }
//     // Normalize each filter to unit area.
//     for (int i = 0; i < nMels; i++) {
//       double s = fbank[i].reduce((a, b) => a + b);
//       if (s != 0) {
//         for (int k = 0; k < nFftBins; k++) {
//           fbank[i][k] /= s;
//         }
//       }
//     }
//     return fbank;
//   }

//   /// Apply the Mel filter bank to the power spectrum.
//   /// [powerSpec] has shape (num_frames, nFFT/2+1).
//   /// Returns a mel spectrogram of shape (num_frames, nMels).
//   List<List<double>> applyMelFilterBank(
//       List<List<double>> powerSpec, List<List<double>> fbank) {
//     int numFrames = powerSpec.length;
//     int nFftBins = powerSpec[0].length;
//     int nMelsLocal = fbank.length;
//     List<List<double>> melSpec =
//         List.generate(numFrames, (_) => List<double>.filled(nMelsLocal, 0.0));
//     for (int i = 0; i < numFrames; i++) {
//       for (int m = 0; m < nMelsLocal; m++) {
//         double sum = 0.0;
//         for (int k = 0; k < nFftBins; k++) {
//           sum += powerSpec[i][k] * fbank[m][k];
//         }
//         melSpec[i][m] = sum;
//       }
//     }
//     return melSpec;
//   }

//   /// Apply log compression to the mel spectrogram.
//   List<List<double>> logCompress(List<List<double>> melSpec) {
//     List<List<double>> result = [];
//     for (var row in melSpec) {
//       result.add(row.map((val) => log(val + logZeroGuardValue)).toList());
//     }
//     return result;
//   }

//   /// Normalize each feature (column) over time.
//   List<List<double>> perFeatureNormalization(List<List<double>> melSpec) {
//     int numFrames = melSpec.length;
//     int numFeatures = melSpec[0].length;
//     List<double> means = List.filled(numFeatures, 0.0);
//     List<double> stds = List.filled(numFeatures, 0.0);
//     for (int j = 0; j < numFeatures; j++) {
//       double sum = 0.0;
//       for (int i = 0; i < numFrames; i++) {
//         sum += melSpec[i][j];
//       }
//       means[j] = sum / numFrames;
//       double varSum = 0.0;
//       for (int i = 0; i < numFrames; i++) {
//         varSum += pow(melSpec[i][j] - means[j], 2);
//       }
//       stds[j] = sqrt(varSum / (numFrames - 1)) + 1e-5;
//     }
//     List<List<double>> normMel =
//         List.generate(numFrames, (_) => List<double>.filled(numFeatures, 0.0));
//     for (int i = 0; i < numFrames; i++) {
//       for (int j = 0; j < numFeatures; j++) {
//         normMel[i][j] = (melSpec[i][j] - means[j]) / stds[j];
//       }
//     }
//     return normMel;
//   }

//   /// Pad the mel spectrogram along the time (frame) dimension so that
//   /// the total number of frames is a multiple of [padTo].
//   List<List<double>> padFrames(List<List<double>> melSpec) {
//     int numFrames = melSpec.length;
//     int remainder = numFrames % padTo;
//     if (remainder == 0) return melSpec;
//     int padFramesCount = padTo - remainder;
//     int numFeatures = melSpec[0].length;
//     List<List<double>> padding = List.generate(
//         padFramesCount, (_) => List<double>.filled(numFeatures, 0.0));
//     return melSpec + padding;
//   }

//   /// Main processing function.
//   /// [rawSignal] is a 1D list of normalized audio samples (values in [-1, 1]).
//   /// Returns the normalized and padded mel spectrogram as a 2D list.
//   List<List<double>> process(List<double> rawSignal) {
//     // 1. Pre-emphasis
//     List<double> emphasized = preemphasisFn(rawSignal);
//     // 2 & 3. STFT
//     List<List<Complex>> stftMatrix = stft(emphasized);
//     // 4. Power Spectrum
//     List<List<double>> powerSpec = powerSpectrum(stftMatrix);
//     // 5. Mel Filter Bank and application
//     List<List<double>> fbank = melFilterBank();
//     List<List<double>> melSpec = applyMelFilterBank(powerSpec, fbank);
//     // 6. Log Compression
//     if (useLog) melSpec = logCompress(melSpec);
//     // 7. Per-Feature Normalization
//     melSpec = perFeatureNormalization(melSpec);
//     // 8. Padding
//     melSpec = padFrames(melSpec);
//     return melSpec;
//   }
// }
import 'dart:math';

class Complex {
  final double real;
  final double imag;

  Complex(this.real, this.imag);

  Complex operator +(Complex other) {
    return Complex(real + other.real, imag + other.imag);
  }

  Complex operator *(Complex other) {
    return Complex(real * other.real - imag * other.imag,
        real * other.imag + imag * other.real);
  }

  double get magnitude => sqrt(real * real + imag * imag);
}

class AudioToMelSpectrogramPreprocessor {
  final int sampleRate;
  final double windowSizeSec;
  final double windowStrideSec;
  late final int nWindowSize;
  late final int nWindowStride;
  final String windowType; // Not used yet, but kept for consistency
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
    this.windowType = 'hann',
    this.preemph = 0.97,
    this.nFFT = 512,
    this.nMels = 64,
    this.lowfreq = 0.0,
    double? highfreq,
    this.useLog = true,
    double? logZeroGuardValue,
    this.padTo = 16,
  })  : highfreq = highfreq ?? sampleRate / 2,
        logZeroGuardValue = logZeroGuardValue ?? pow(2, -24).toDouble() {
    nWindowSize = (windowSizeSec * sampleRate).round();
    nWindowStride = (windowStrideSec * sampleRate).round();
  }

  List<double> preemphasisFn(List<double> signal) {
    if (signal.isEmpty) {
      return signal;
    }
    List<double> emphasized = List.filled(signal.length, 0);
    emphasized[0] = signal[0];
    for (int i = 1; i < signal.length; i++) {
      emphasized[i] = signal[i] - preemph * signal[i - 1];
    }
    return emphasized;
  }

  List<double> hannWindow(int length) {
    return List.generate(
        length, (n) => 0.5 * (1 - cos(2 * pi * n / (length - 1))));
  }

  List<List<double>> stft(List<double> signal) {
    int numFrames = ((signal.length - nWindowSize) / nWindowStride).floor() + 1;
    List<double> window = hannWindow(nWindowSize);
    List<List<double>> stftMatrix = [];

    for (int i = 0; i < numFrames; i++) {
      int start = i * nWindowStride;
      List<double> frame = signal
          .sublist(start, start + nWindowSize)
          .map((x) =>
              x * window[signal.sublist(start, start + nWindowSize).indexOf(x)])
          .toList();
      List<double> padded = List.filled(nFFT, 0);
      padded.setRange(0, frame.length, frame);

      List<Complex> fftFrame = [];
      for (int k = 0; k < nFFT; k++) {
        Complex sum = Complex(0, 0);
        for (int n = 0; n < nFFT; n++) {
          sum += Complex(padded[n] * cos(-2 * pi * k * n / nFFT),
              padded[n] * sin(-2 * pi * k * n / nFFT));
        }
        fftFrame.add(sum);
      }
      stftMatrix.add(
          fftFrame.sublist(0, nFFT ~/ 2 + 1).map((e) => e.magnitude).toList());
    }
    return stftMatrix;
  }

  List<List<double>> powerSpectrum(List<List<double>> stftMatrix) {
    return stftMatrix.map((row) => row.map((x) => x * x).toList()).toList();
  }

  double hzToMel(double hz) {
    return 2595 * log(1 + hz / 700) / log(10);
  }

  double melToHz(double mel) {
    return 700 * (pow(10, mel / 2595) - 1);
  }

  List<double> linspace(double start, double end, int num) {
    double step = (end - start) / (num - 1);
    return List.generate(num, (i) => start + i * step);
  }

  List<List<double>> melFilterBank() {
    int nFftBins = nFFT ~/ 2 + 1;
    double melLow = hzToMel(lowfreq);
    double melHigh = hzToMel(highfreq);
    List<double> melPoints = linspace(melLow, melHigh, nMels + 2);
    List<double> hzPoints = melPoints.map((m) => melToHz(m)).toList();
    List<int> bins = hzPoints
        .map((hz) => ((hz / (sampleRate / 2)) * (nFftBins - 1)).floor())
        .toList();

    List<List<double>> fbank =
        List.generate(nMels, (_) => List.filled(nFftBins, 0));

    for (int m = 1; m <= nMels; m++) {
      int fMMinus = bins[m - 1];
      int fM = bins[m];
      int fMPlus = bins[m + 1];
      for (int k = fMMinus; k < fM; k++) {
        fbank[m - 1][k] = (k - fMMinus) / (fM - fMMinus).toDouble();
      }
      for (int k = fM; k < fMPlus; k++) {
        fbank[m - 1][k] = (fMPlus - k) / (fMPlus - fM).toDouble();
      }
    }

    for (int i = 0; i < nMels; i++) {
      double s = fbank[i].reduce((a, b) => a + b);
      if (s != 0) {
        fbank[i] = fbank[i].map((x) => x / s).toList();
      }
    }
    return fbank;
  }

  List<List<double>> applyMelFilterBank(
      List<List<double>> powerSpec, List<List<double>> fbank) {
    List<List<double>> melSpectrogram =
        List.generate(powerSpec.length, (i) => List.filled(nMels, 0));
    for (int i = 0; i < powerSpec.length; i++) {
      for (int j = 0; j < nMels; j++) {
        for (int k = 0; k < powerSpec[i].length; k++) {
          melSpectrogram[i][j] += powerSpec[i][k] * fbank[j][k];
        }
      }
    }
    return melSpectrogram;
  }

  List<List<double>> logCompress(List<List<double>> melSpec) {
    return melSpec
        .map((row) => row.map((x) => log(x + logZeroGuardValue)).toList())
        .toList();
  }

  List<List<double>> perFeatureNormalization(List<List<double>> melSpec) {
    int numFrames = melSpec.length;
    int numFeatures = melSpec[0].length;

    List<double> means = List.filled(numFeatures, 0);
    List<double> stds = List.filled(numFeatures, 0);

    for (int j = 0; j < numFeatures; j++) {
      double sum = 0;
      for (int i = 0; i < numFrames; i++) {
        sum += melSpec[i][j];
      }
      means[j] = sum / numFrames;

      double sqDiffSum = 0;
      for (int i = 0; i < numFrames; i++) {
        sqDiffSum += pow(melSpec[i][j] - means[j], 2);
      }
      stds[j] = sqrt(sqDiffSum / (numFrames - 1)) + 1e-5;
    }

    List<List<double>> normMel =
        List.generate(numFrames, (i) => List.filled(numFeatures, 0));
    for (int i = 0; i < numFrames; i++) {
      for (int j = 0; j < numFeatures; j++) {
        normMel[i][j] = (melSpec[i][j] - means[j]) / stds[j];
      }
    }
    return normMel;
  }

  List<List<double>> padFrames(List<List<double>> melSpec) {
    int numFrames = melSpec.length;
    int remainder = numFrames % padTo;
    if (remainder == 0) {
      return melSpec;
    }
    int padFramesCount = padTo - remainder;
    List<List<double>> padding =
        List.generate(padFramesCount, (_) => List.filled(melSpec[0].length, 0));
    return melSpec + padding;
  }

  List<List<double>> process(List<double> rawSignal) {
    // 1. Pre-emphasis
    List<double> emphasized = preemphasisFn(rawSignal);
    // 2 & 3. STFT
    List<List<double>> stftMatrix = stft(emphasized);
    // 4. Power Spectrum
    List<List<double>> powerSpec = powerSpectrum(stftMatrix);
    // 5. Mel Filter Bank and application
    List<List<double>> fbank = melFilterBank();
    List<List<double>> melSpec = applyMelFilterBank(powerSpec, fbank);
    // 6. Log Compression
    if (useLog) {
      melSpec = logCompress(melSpec);
    }
    // 7. Per-Feature Normalization
    melSpec = perFeatureNormalization(melSpec);
    // 8. Padding
    melSpec = padFrames(melSpec);
    return melSpec;
  }
}

import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:ffi/ffi.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
// Note: flutter/services.dart (rootBundle) no longer needed - model downloaded from Firebase Storage
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// FFI bindings for the native ASR library
typedef InitSessionC = Uint64 Function(Pointer<Utf8> onnxPath, Int32 modelType);
typedef InitSessionDart = int Function(Pointer<Utf8> onnxPath, int modelType);

typedef TranscribeC = Pointer<Utf8> Function(
    Uint64 handle, Pointer<Utf8> wavPath);
typedef TranscribeDart = Pointer<Utf8> Function(
    int handle, Pointer<Utf8> wavPath);

typedef FreeCStringC = Void Function(Pointer<Utf8> ptr);
typedef FreeCStringDart = void Function(Pointer<Utf8> ptr);

typedef DisposeC = Void Function(Uint64 handle);
typedef DisposeDart = void Function(int handle);

class ASRService {
  static ASRService? _instance;
  static ASRService get instance => _instance ??= ASRService._();

  ASRService._();

  DynamicLibrary? _lib;
  int? _sessionHandle;
  String? _modelPath;
  bool _isInitialized = false;
  String? _lastError;

  // Debug flag - set to false to force local model usage (no API fallback)
  bool _allowAPIFallback = true;

  late InitSessionDart _initSession;
  late TranscribeDart _transcribe;
  late FreeCStringDart _freeCString;
  late DisposeDart _dispose;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Set whether to allow API fallback (for debugging)
  void setAllowAPIFallback(bool allow) {
    _allowAPIFallback = allow;
    print('API fallback ${allow ? 'enabled' : 'disabled'}');
  }

  /// Get initialization status and last error
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'sessionHandle': _sessionHandle,
      'modelPath': _modelPath,
      'lastError': _lastError,
      'platform': Platform.operatingSystem,
      'allowAPIFallback': _allowAPIFallback,
    };
  }

  /// Initialize the ASR service
  Future<bool> initialize({Function(double)? onDownloadProgress}) async {
    if (_isInitialized) {
      print('ASR service already initialized, skipping');
      return true;
    }

    print('=== ASR Service Initialization ===');
    print('Platform: ${Platform.operatingSystem}');
    print('Allow API fallback: $_allowAPIFallback');

    if (Platform.isAndroid) {
      final result = await _initializeAndroid(onDownloadProgress: onDownloadProgress);
      _isInitialized = result;
      print('Android ASR initialization result: $result');
      return result;
    } else {
      print('iOS platform detected - using API only');
      _isInitialized = true;
      return true; // iOS doesn't need initialization as it uses API
    }
  }

  /// Initialize the Android native ASR
  Future<bool> _initializeAndroid({Function(double)? onDownloadProgress}) async {
    try {
      print('Loading native library: libNeMoOnnxSharp.so');
      // Load the native library
      _lib = DynamicLibrary.open('libNeMoOnnxSharp.so');
      print('✓ Native library loaded successfully');

      // Get function pointers
      print('Getting function pointers...');
      _initSession =
          _lib!.lookupFunction<InitSessionC, InitSessionDart>('InitSession');
      _transcribe =
          _lib!.lookupFunction<TranscribeC, TranscribeDart>('Transcribe');
      _freeCString =
          _lib!.lookupFunction<FreeCStringC, FreeCStringDart>('FreeCString');
      _dispose = _lib!.lookupFunction<DisposeC, DisposeDart>('Dispose');
      print('✓ Function pointers obtained');

      // Get or download the model file
      print('Getting model path...');
      _modelPath = await _getModelPath(onProgress: onDownloadProgress);
      if (_modelPath == null) {
        _lastError = 'Failed to get model path';
        print('✗ $_lastError');
        return false;
      }
      print('✓ Model path: $_modelPath');

      // Verify model file exists and check size
      final modelFile = File(_modelPath!);
      if (!await modelFile.exists()) {
        _lastError = 'Model file does not exist at path: $_modelPath';
        print('✗ $_lastError');
        return false;
      }

      final fileSize = await modelFile.length();
      print(
          '✓ Model file exists, size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      // Initialize the session with modelType 1 (Soloni)
      print('Initializing ASR session...');
      final modelPathUtf8 = _modelPath!.toNativeUtf8();
      _sessionHandle = _initSession(modelPathUtf8, 1);
      malloc.free(modelPathUtf8);

      if (_sessionHandle == null || _sessionHandle == 0) {
        _lastError = 'Failed to initialize ASR session - session handle is 0';
        print('✗ $_lastError');
        return false;
      }

      print('✓ ASR service initialized successfully');
      print('Session handle: $_sessionHandle');
      return true;
    } catch (e, stack) {
      _lastError = 'Failed to initialize ASR service: $e';
      print('✗ $_lastError');
      FirebaseCrashlytics.instance.recordError(e, stack,
          reason: 'ASR Android initialization');
      return false;
    }
  }

  /// Get the model path, downloading from Firebase Storage if necessary
  Future<String?> _getModelPath({Function(double)? onProgress}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingPath = prefs.getString('asr_model_path');

      if (existingPath != null &&
          existingPath.contains('soloni-be-kalan') &&
          await File(existingPath).exists()) {
        print('Using existing model at: $existingPath');
        return existingPath;
      }

      // Download model from Firebase Storage
      final dir = await getApplicationDocumentsDirectory();
      final modelFile = File('${dir.path}/soloni-be-kalan.onnx');

      if (!await modelFile.exists()) {
        print('Downloading ASR model from Firebase Storage...');
        final ref = FirebaseStorage.instance.ref('models/soloni-be-kalan.onnx');
        final downloadTask = ref.writeToFile(modelFile);

        downloadTask.snapshotEvents.listen((event) {
          if (event.totalBytes > 0) {
            final progress = event.bytesTransferred / event.totalBytes;
            print('Download progress: ${(progress * 100).toStringAsFixed(1)}%');
            onProgress?.call(progress);
          }
        });

        await downloadTask;
        print('Model downloaded successfully');
      } else {
        print('Model already exists in app directory');
      }

      await prefs.setString('asr_model_path', modelFile.path);
      return modelFile.path;
    } catch (e) {
      print('Error getting model path: $e');
      return null;
    }
  }

  /// Transcribe audio file
  Future<String?> transcribeAudio(String audioFilePath) async {
    print('=== ASR Transcription Request ===');
    print('Audio file: $audioFilePath');
    print('Platform: ${Platform.operatingSystem}');

    // Verify audio file exists
    final audioFile = File(audioFilePath);
    if (!await audioFile.exists()) {
      print('✗ Audio file does not exist: $audioFilePath');
      return null;
    }

    final fileSize = await audioFile.length();
    print('Audio file size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

    if (Platform.isAndroid) {
      return await _transcribeAndroid(audioFilePath);
    } else if (Platform.isIOS) {
      return await _transcribeIOS(audioFilePath);
    }
    return null;
  }

  /// Android native transcription
  Future<String?> _transcribeAndroid(String audioFilePath) async {
    print('--- Android Native Transcription ---');

    if (_sessionHandle == null || _sessionHandle == 0) {
      final error = 'ASR session not initialized (handle: $_sessionHandle)';
      print('✗ $error');
      _lastError = error;

      if (_allowAPIFallback) {
        print('Falling back to API...');
        return await _transcribeIOS(audioFilePath);
      } else {
        print('API fallback disabled - returning null');
        return null;
      }
    }

    try {
      print('Starting native transcription...');
      final audioPathUtf8 = audioFilePath.toNativeUtf8();
      final resultPtr = _transcribe(_sessionHandle!, audioPathUtf8);
      malloc.free(audioPathUtf8);

      if (resultPtr.address == 0) {
        final error = 'Native transcription failed - null result pointer';
        print('✗ $error');
        _lastError = error;

        if (_allowAPIFallback) {
          print('Falling back to API...');
          return await _transcribeIOS(audioFilePath);
        } else {
          print('API fallback disabled - returning null');
          return null;
        }
      }

      final result = resultPtr.toDartString();
      _freeCString(resultPtr);

      print('✓ Native transcription successful');
      print('Result length: ${result.length} characters');
      print(
          'Result preview: ${result.length > 50 ? result.substring(0, 50) + "..." : result}');

      return result;
    } catch (e, stack) {
      final error = 'Error during Android transcription: $e';
      print('✗ $error');
      _lastError = error;
      FirebaseCrashlytics.instance.recordError(e, stack,
          reason: 'ASR Android transcription');

      if (_allowAPIFallback) {
        print('Falling back to API...');
        return await _transcribeIOS(audioFilePath);
      } else {
        print('API fallback disabled - returning null');
        return null;
      }
    }
  }

  /// iOS API-based transcription
  Future<String?> _transcribeIOS(String audioFilePath) async {
    print('--- API Transcription ---');
    try {
      // Get the API endpoint from Firebase
      print('Getting API endpoint from Firebase...');
      DocumentSnapshot<Map<String, dynamic>> serve =
          await _firestore.collection('api').doc("SmKsDBpP7jBAKeEtckCD").get();
      final serverUrl = serve.data()!['key'];
      final uri = Uri.parse(serverUrl);
      print('API URL: $serverUrl');

      final audioFile = File(audioFilePath);
      final request = http.MultipartRequest('POST', uri);

      // Attach the audio file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
          contentType: MediaType('audio', 'wav'),
        ),
      );

      print('Sending request to API...');
      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final result = jsonDecode(respStr);
        final transcription = result["transcription"];

        print('✓ API transcription successful');
        print('Result length: ${transcription?.length ?? 0} characters');
        print(
            'Result preview: ${transcription != null && transcription.length > 50 ? transcription.substring(0, 50) + "..." : transcription}');

        return transcription;
      } else {
        final error =
            "API transcription failed with status code ${response.statusCode}";
        print('✗ $error');
        _lastError = error;
        return null;
      }
    } catch (e, stack) {
      final error = 'Error during API transcription: $e';
      print('✗ $error');
      _lastError = error;
      FirebaseCrashlytics.instance.recordError(e, stack,
          reason: 'ASR API transcription');
      return null;
    }
  }

  /// Dispose of the ASR service
  void dispose() {
    print('=== ASR Service Disposal ===');
    if (Platform.isAndroid && _sessionHandle != null && _sessionHandle != 0) {
      print('Disposing ASR session handle: $_sessionHandle');
      _dispose(_sessionHandle!);
      _sessionHandle = null;
    }
    _isInitialized = false;
    print('ASR service disposed');
  }
}

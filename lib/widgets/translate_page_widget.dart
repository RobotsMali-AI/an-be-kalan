// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class TranslationPage extends StatefulWidget {
//   const TranslationPage({super.key});

//   @override
//   _TranslationPageState createState() => _TranslationPageState();
// }

// class _TranslationPageState extends State<TranslationPage> {
//   final TextEditingController _textController = TextEditingController();
//   String _translatedText = "";
//   String _sourceLanguage = "fra_Latn";
//   String _targetLanguage = "bam_Latn";
//   bool _isTranslating = false;

//   final Map<String, String> _bambaraCharacterFixes = {
//     "Ã²": "ɔ",
//     "Ã¸": "ɛ",
//     "Ã": "ŋ",
//     "¨": "e"
//   };

//   String _decodeBambaraText(String input) {
//     _bambaraCharacterFixes.forEach((wrong, correct) {
//       input = input.replaceAll(wrong, correct);
//     });
//     return input;
//   }

//   Future<void> _translateText() async {
//     if (_textController.text.isEmpty || _isTranslating) return;

//     setState(() => _isTranslating = true);

//     try {
//       final response = await http.post(
//         Uri.parse('https://djelia.cloud/api/v1/models/translate'),
//         headers: {
//           "x-api-key": "6f34b9ac-7eb0-4319-8a0f-dcbb5cb5a7a3",
//           "Content-Type": "application/json"
//         },
//         body: jsonEncode({
//           "text": _textController.text,
//           "source": _sourceLanguage,
//           "target": _targetLanguage
//         }),
//       );

//       if (response.statusCode == 200) {
//         final decodedResponse = jsonDecode(response.body);
//         setState(() {
//           _translatedText = _decodeBambaraText(decodedResponse['text']);
//           print(_translatedText);
//         });
//       } else {
//         _showErrorSnackbar('Translation failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       _showErrorSnackbar('Connection error: ${e.toString()}');
//     } finally {
//       setState(() => _isTranslating = false);
//     }
//   }

//   void _swapLanguages() {
//     setState(() {
//       final temp = _sourceLanguage;
//       _sourceLanguage = _targetLanguage;
//       _targetLanguage = temp;
//     });
//   }

//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.redAccent,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           "Taajaboli",
//           style: TextStyle(
//             color: Colors.white, // Ensure good contrast
//             fontSize: 20, // Increase readability
//             fontWeight: FontWeight.bold, // Make it stand out
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.black, // Keep strong contrast
//         elevation: 0,
//         iconTheme: const IconThemeData(
//             color: Colors.white), // Ensure icons are visible
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildLanguageSelector(),
//             const SizedBox(height: 20),
//             _buildTranslationInput(),
//             const SizedBox(height: 20),
//             _buildTranslateButton(),
//             const SizedBox(height: 20),
//             _buildTranslationOutput(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLanguageSelector() {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Row(
//           children: [
//             _buildLanguageDropdown(_sourceLanguage, true),
//             IconButton(
//               icon: const Icon(Icons.swap_vert),
//               onPressed: _swapLanguages,
//               tooltip: 'Swap languages',
//             ),
//             _buildLanguageDropdown(_targetLanguage, false),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLanguageDropdown(String value, bool isSource) {
//     return Expanded(
//       child: DropdownButtonFormField<String>(
//         isExpanded: true,
//         value: value,
//         decoration: InputDecoration(
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
//         ),
//         items: const [
//           DropdownMenuItem(value: "fra_Latn", child: Text("Faransi 🇫🇷")),
//           DropdownMenuItem(value: "eng_Latn", child: Text("Angilɛ 🇬🇧")),
//           DropdownMenuItem(value: "bam_Latn", child: Text("Bamanankan 🇲🇱")),
//         ],
//         onChanged: (newValue) => setState(() => isSource
//             ? _sourceLanguage = newValue!
//             : _targetLanguage = newValue!),
//       ),
//     );
//   }

//   Widget _buildTranslationInput() {
//     return TextField(
//       controller: _textController,
//       maxLines: 4,
//       decoration: InputDecoration(
//         labelText: "Kuma dɔ sɛbɛ",
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
//         filled: true,
//         suffixIcon: IconButton(
//           icon: const Icon(Icons.clear),
//           onPressed: () => _textController.clear(),
//         ),
//       ),
//     );
//   }

//   Widget _buildTranslateButton() {
//     return ElevatedButton(
//       onPressed: _isTranslating ? null : _translateText,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.black,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//       child: _isTranslating
//           ? const CircularProgressIndicator(color: Colors.white)
//           : const Text(
//               "Taa jabi",
//               style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white),
//             ),
//     );
//   }

//   Widget _buildTranslationOutput() {
//     return Expanded(
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Text("Taa jabi sɔrɔ:",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Text(_translatedText,
//                       style: const TextStyle(fontSize: 16, height: 1.5)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = "";
  String _sourceLanguage = "fra_Latn";
  String _targetLanguage = "bam_Latn";
  bool _isTranslating = false;

  final Map<String, String> _bambaraCharacterFixes = {
    "Ã²": "ɔ",
    "Ã¸": "ɛ",
    "Ã": "ŋ",
    "¨": "e"
  };

  String _decodeBambaraText(String input) {
    _bambaraCharacterFixes.forEach((wrong, correct) {
      input = input.replaceAll(wrong, correct);
    });
    return input;
  }

  Future<void> _translateText() async {
    if (_textController.text.isEmpty || _isTranslating) return;

    setState(() => _isTranslating = true);

    try {
      final response = await http.post(
        Uri.parse('https://djelia.cloud/api/v1/models/translate'),
        headers: {
          "x-api-key": "6f34b9ac-7eb0-4319-8a0f-dcbb5cb5a7a3",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "text": _textController.text,
          "source": _sourceLanguage,
          "target": _targetLanguage
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        setState(() {
          _translatedText = _decodeBambaraText(decodedResponse['text']);
          print(_translatedText);
        });
      } else {
        _showErrorSnackbar('Translation failed: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Connection error: ${e.toString()}');
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Taajaboli",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLanguageSelector(),
            const SizedBox(height: 20),
            _buildTranslationInput(),
            const SizedBox(height: 20),
            _buildTranslateButton(),
            const SizedBox(height: 20),
            _buildTranslationOutput(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            _buildLanguageDropdown(_sourceLanguage, true),
            IconButton(
              icon: const Icon(Icons.swap_vert, color: Colors.black),
              onPressed: _swapLanguages,
              tooltip: 'Swap languages',
            ),
            _buildLanguageDropdown(_targetLanguage, false),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(String value, bool isSource) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: value,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          filled: true,
          fillColor: Colors.white,
        ),
        items: const [
          DropdownMenuItem(value: "fra_Latn", child: Text("Farancɛ 🇫🇷")),
          DropdownMenuItem(value: "eng_Latn", child: Text("Angilɛ 🇬🇧")),
          DropdownMenuItem(value: "bam_Latn", child: Text("Bamanankan 🇲🇱")),
        ],
        onChanged: (newValue) => setState(() => isSource
            ? _sourceLanguage = newValue!
            : _targetLanguage = newValue!),
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
      ),
    );
  }

  Widget _buildTranslationInput() {
    return TextField(
      controller: _textController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: "Kuma dɔ sɛbɛ",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.black),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.black),
          onPressed: () => _textController.clear(),
        ),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  Widget _buildTranslateButton() {
    return ElevatedButton(
      onPressed: _isTranslating ? null : _translateText,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: _isTranslating
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "Taa jabi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildTranslationOutput() {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Taa jabi sɔrɔ:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _translatedText,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

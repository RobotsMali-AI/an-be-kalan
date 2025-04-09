import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_translate_api/google_translate_api.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = "";
  String _sourceLanguage = "fr";
  String _targetLanguage = "bm";
  bool _isTranslating = false;

  Future<void> _translateText() async {
    if (_textController.text.isEmpty || _isTranslating) return;

    setState(() => _isTranslating = true);

    try {
      String apiKey = "";
      try {
        apiKey = await rootBundle.loadString('assets/secret.txt');
      } catch (e) {
        _showErrorSnackbar('Failed to load API key: $e');
        return;
      }
      final googleTranslate = GoogleTranslate(apiKey);
      final translation = await googleTranslate.translate(
        text: _textController.text,
        sourceLang: _sourceLanguage,
        targetLang: _targetLanguage,
      );
      setState(() {
        _translatedText = translation;
      });
    } catch (e) {
      _showErrorSnackbar('Jɛɲɔgɔnya fili: ${e.toString()}');
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
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            _buildLanguageDropdown(_sourceLanguage, true),
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.swap_vert, color: Colors.white),
                onPressed: _swapLanguages,
                tooltip: 'Kanw ɲɔgɔn falen-falen',
              ),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        items: const [
          DropdownMenuItem(value: "fr", child: Text("Faransikan 🇫🇷")),
          DropdownMenuItem(value: "en", child: Text("Angilɛkan 🇬🇧")),
          DropdownMenuItem(value: "bm", child: Text("Bamanankan 🇲🇱")),
        ],
        onChanged: (newValue) => setState(() => isSource
            ? _sourceLanguage = newValue!
            : _targetLanguage = newValue!),
        dropdownColor: Colors.white,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
      ),
    );
  }

  Widget _buildTranslationInput() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: _textController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: "Kuma dɔ sɛbɛ",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () => _textController.clear(),
            ),
          ),
        ),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildTranslateButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isTranslating ? null : _translateText,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isTranslating
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Ka bamanankan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildTranslationOutput() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Ka bamanankan sɔrɔ:",
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

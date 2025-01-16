import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomRichetext extends StatelessWidget {
  const CustomRichetext(
      {super.key, required this.text1, required this.text2, this.onPressed});
  final String text1;
  final String text2;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 18, color: Colors.black),
        children: [
          TextSpan(text: text1),
          TextSpan(
            text: text2,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()..onTap = onPressed,
          ),
        ],
      ),
    );
  }
}

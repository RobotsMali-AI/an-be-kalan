import 'package:flutter/material.dart';

class CustomTextFormFieldWidget extends StatelessWidget {
  const CustomTextFormFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.errorText,
    this.prefixIcon,
    this.obscureText = false,
    this.inputType = TextInputType.text,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String hintText;
  final String errorText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType inputType;
  final List<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Theme.of(context).primaryColor)
              : null,
          filled: true,
          fillColor: Colors.grey[200], // Light background for better visibility
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
            borderSide: BorderSide.none, // No border for cleaner look
          ),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        ),
        obscureText: obscureText,
        keyboardType: inputType,
        autofillHints: autofillHints,
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            if (inputType == TextInputType.emailAddress) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
            } else if (inputType == TextInputType.number) {
              final numberRegex = RegExp(r'^[0-9]+$');
              if (!numberRegex.hasMatch(value)) {
                return 'Please enter a valid number';
              }
            }
          } else {
            return errorText;
          }
          return null;
          //value != null && value.isNotEmpty ? null : errorText,
        });
  }
}

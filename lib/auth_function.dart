import 'package:flutter/material.dart';
import 'package:literacy_app/widgets/snackbar.dart';

import 'main.dart';

Future<void> resetPassword(BuildContext context) async {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing the dialog by tapping outside
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Segin ka Password Lasegin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aw ye aw ka imeyili ladɛrɛsi sɛbɛn walasa ka tɔgɔlasɛbɛn lasegincogo ladɛrɛsi sɔrɔ.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Imɛli ladɛrɛsi',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email de wajibiyalen don';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Aw ye bataki ci min bɛ se ka kɛ';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('ka dankari'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final email = emailController.text.trim();
                try {
                  await auth.sendPasswordResetEmail(email: email);
                  Navigator.of(context).pop(); // Close the dialog
                  showSnackbar(context, 'Password reset Imɛli cilen don.');
                } catch (e) {
                  showSnackbar(
                      context, 'Misali la, i ye password reset Imɛli ci.');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ka ci'),
          ),
        ],
      );
    },
  );
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:image_picker/image_picker.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _messageFocus = FocusNode();

  bool _isSending = false;
  XFile? _selectedImage;

  Future<void> _sendFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final String name = _nameController.text;
    final String email = _emailController.text;
    final String message = _messageController.text;

    // final smtpServer = gmail('anbekalanapp@robotsmali.org', 'K@lan-kadi.bam');
    final smtpServer = SmtpServer(
      'mail.robotsmali.org',
      port: 465,
      ssl: true,
      username: 'anbekalanapp@robotsmali.org',
      password: 'K@lan-kadi.bam',
    );

    final emailMessage = Message()
      ..from = Address(email, name)
      ..recipients.add('anbekalanapp@robotsmali.org')
      ..subject = 'Feedback kura bɔra $name'
      ..text = message;

    if (_selectedImage != null) {
      emailMessage.attachments.add(FileAttachment(File(_selectedImage!.path)));
    }

    try {
      await send(emailMessage, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Jaabiw cilen don ka ɲɛ!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _clearForm();
    } on MailerException catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A ma se ka ci bila: ${e.message}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Aw ye a lajɛ kokura',
            textColor: Colors.white,
            onPressed: _sendFeedback,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Misali min ma labɛn: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
    setState(() {
      _selectedImage = null;
    });
    _nameFocus.requestFocus();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Colors.grey[900]!],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Aw ye hakilinaw ci',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              floating: true,
              actions: [
                IconButton(
                  onPressed: _isSending ? null : _sendFeedback,
                  icon: _isSending
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                  tooltip: 'Aw ye hakilinaw ci',
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        nextFocus: _emailFocus,
                        label: 'I tɔgɔ',
                        hint: 'I tɔgɔ sɛbɛn',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        nextFocus: _messageFocus,
                        label: 'Aw ka imɛli',
                        hint: 'Aw ye aw ka imɛli sɛbɛn',
                        icon: Icons.email,
                        isEmail: true,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _messageController,
                        focusNode: _messageFocus,
                        label: 'Bataki',
                        hint: 'Aw ka hakilinaw sɛbɛn yan...',
                        icon: Icons.message,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Ja nɔrɔ a la'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (_selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'Ja sugandilen: ${_selectedImage!.name}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    bool isEmail = false,
    int maxLines = 1,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Colors.white70, fontWeight: FontWeight.w500),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Aw ye don a kɔnɔ $label';
          }
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Aw ye bataki ci min bɛ se ka kɛ';
          }
          return null;
        },
        onFieldSubmitted: (_) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          } else {
            _sendFeedback();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _messageFocus.dispose();
    super.dispose();
  }
}

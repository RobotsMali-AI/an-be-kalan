import 'dart:io';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/main.dart' show auth;
import 'package:literacy_app/models/Users.dart';
import 'package:provider/provider.dart';

const placeholderImage =
    'https://drive.google.com/uc?export=download&id=1_egpUE2P2KJ3WVQ44iCT0ux6f_KdJVdO';

class ProfilePage extends StatefulWidget {
  final Users userData;
  final User user;

  const ProfilePage({super.key, required this.user, required this.userData});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController controller;
  String? photoURL;
  bool showSaveButton = false;
  bool isLoading = false;

  // Mock data for stats
  final int totalExperience = 1250;
  final String totalReadingTime = "25h 30m";
  final int totalBooksCompleted = 42;

  @override
  void initState() {
    controller = TextEditingController(text: widget.user.displayName);
    controller.addListener(_onNameChanged);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_onNameChanged);
    super.dispose();
  }

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void _onNameChanged() {
    setState(() {
      showSaveButton = controller.text != widget.user.displayName &&
          controller.text.isNotEmpty;
    });
  }

  Future updateDisplayName() async {
    await widget.user.updateDisplayName(controller.text);
    setState(() {
      showSaveButton = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('I togo yele mala')),
    );
  }

  Future<void> _uploadProfilePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setIsLoading();

      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${widget.user.uid}.jpg');
        await ref.putFile(File(pickedImage.path));
        final downloadURL = await ref.getDownloadURL();

        await widget.user.updatePhotoURL(downloadURL);
        if (!mounted) return;
        setState(() {
          photoURL = downloadURL;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload picture')),
          );
        }
      } finally {
        if (mounted) {
          setIsLoading();
        }
      }
    }
  }

  Future<void> _signOut() async {
    if (widget.user.isAnonymous) {
      await context.read<ApiFirebaseService>().deleteUserData(widget.user.uid);
      await widget.user.delete();
    }
    await auth.signOut();
    await GoogleSignIn().signOut();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final random = math.Random();
    final randomColor = Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      0.1, // Light overlay
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.grey.shade100,
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(
                        widget.user.photoURL ?? placeholderImage,
                      ),
                    ),
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Colors.transparent, randomColor],
                          stops: const [0.7, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Material(
                        color: Colors.grey.shade300,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: _uploadProfilePicture,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child:
                                Icon(Icons.camera_alt, color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  onEditingComplete: updateDisplayName,
                  textAlign: TextAlign.center,
                  controller: controller,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: "Enter your display name",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildStatCard(
                            title: "Experience",
                            value: "${widget.userData.xp} XP",
                            icon: Icons.star,
                            backgroundColor: Colors.blue.shade100,
                          ),
                          const SizedBox(height: 10),
                          _buildStatCard(
                            title: "Total Reading Time",
                            value: widget.userData.totalReadingTime.toString(),
                            icon: Icons.timer,
                            backgroundColor: Colors.green.shade100,
                          ),
                          const SizedBox(height: 10),
                          _buildStatCard(
                            title: "Books Completed",
                            value: "${widget.userData.completedBooks.length}",
                            icon: Icons.book,
                            backgroundColor: Colors.orange.shade100,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _signOut,
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color backgroundColor,
  }) {
    return Card(
      color: backgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon, color: Colors.black54),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

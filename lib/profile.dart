import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/main.dart' show auth;
import 'package:literacy_app/models/Users.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

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

  @override
  void initState() {
    super.initState();
    photoURL = widget.user.photoURL; // Initialize with current user photo
    controller = TextEditingController(text: widget.user.displayName);
    controller.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onNameChanged);
    controller.dispose();
    super.dispose();
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
      const SnackBar(content: Text('Jiracogo tɔgɔ kura donna')),
    );
  }

  Future<List<String>> fetchAvatarUrls() async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('avatars');
      final listResult = await storageRef.listAll();
      final urls = <String>[];
      for (var item in listResult.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }
      return urls;
    } catch (e) {
      print('Error fetching avatars: $e');
      return [];
    }
  }

  Future<void> _chooseAvatar() async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white, // flat white background for a simple look
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Aw ye aw ka ja ɲuman sugandi!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // black text for clarity
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<String>>(
                    future: fetchAvatarUrls(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Ayiwa! Fɛn dɔ ma ɲɛ.'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Ja si tɛ yen sisan.'));
                      } else {
                        final urls = snapshot.data!;
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: urls.length,
                          itemBuilder: (context, index) {
                            final avatarUrl = urls[index];
                            return GestureDetector(
                              onTap: () async {
                                try {
                                  await widget.user.updatePhotoURL(avatarUrl);
                                  if (!mounted) return;
                                  setState(() {
                                    photoURL = avatarUrl;
                                  });
                                  Navigator.pop(context);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Ja kura donna!')),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Ayiwa! A ma se ka ja kura ye.')),
                                    );
                                  }
                                }
                              },
                              child: AnimatedScale(
                                scale: 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(avatarUrl,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      0.1,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'N ka Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 1,
        iconTheme:
            const IconThemeData(color: Colors.white), // Adjusted for visibility
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Ka bɔ', // Optional tooltip for accessibility
          ),
        ],
      ),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.grey.shade100),
            ),
            Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(
                        photoURL ?? placeholderImage,
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
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _chooseAvatar,
                  icon: const Icon(Icons.person),
                  label: const Text('Ja sugandi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  onEditingComplete: updateDisplayName,
                  textAlign: TextAlign.center,
                  controller: controller,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: "I ka jiracogo tɔgɔ sɛbɛn",
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
                            title: "Dɔnniya",
                            value: "${widget.userData.xp} XP",
                            icon: Icons.star,
                            backgroundColor: Colors.blue.shade100,
                          ),
                          const SizedBox(height: 10),
                          _buildStatCard(
                            title: "Kalan waati bɛɛ lajɛlen",
                            value: widget.userData.totalReadingTime.toString(),
                            icon: Icons.timer,
                            backgroundColor: Colors.green.shade100,
                          ),
                          const SizedBox(height: 10),
                          _buildStatCard(
                            title: "Gafew dafara",
                            value: "${widget.userData.completedBooks.length}",
                            icon: Icons.book,
                            backgroundColor: Colors.orange.shade100,
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:literacy_app/auth.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/feedback.dart';
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
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Aw ye aw ka ja ɲuman sugandi!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<List<String>>(
                    future: fetchAvatarUrls(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Ayiwa! Fɛn dɔ ma ɲɛ.',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'Ja si tɛ yen sisan.',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                            ),
                          ),
                        );
                      } else {
                        final urls = snapshot.data!;
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
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
                                        content: Text(
                                          'Ja kura donna!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        backgroundColor: Colors.black,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Ayiwa! A ma se ka ja kura ye.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        backgroundColor: Colors.black,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: AnimatedScale(
                                scale: 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                    ),
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

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('I baana i ka jiracogo faga wa?'),
        content: const Text('I ye i jiracogo faga. I tɛ se ka segin o la.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ayi'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ɛɛ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        isLoading = true;
      });
      try {
        await context
            .read<ApiFirebaseService>()
            .deleteUserData(widget.user.uid);
        await widget.user.delete();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const AuthGate()));
        // After deletion, auth state listener should navigate to sign-in page
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          print(e);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ayiwa! Jiracogo ma se ka faga: $e')),
          );
        }
      }
    }
  }

  Future<void> _showFeedbackDialog() async {
    final feedbackController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lafili'),
        content: TextField(
          controller: feedbackController,
          decoration: const InputDecoration(hintText: 'I ka lafili sɛbɛn'),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ayi'),
          ),
          TextButton(
            onPressed: () async {
              final feedback = feedbackController.text.trim();
              if (feedback.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aw ye lafili sɛbɛn')),
                );
              } else {
                try {
                  // await context
                  //     .read<ApiFirebaseService>()
                  //     .saveFeedback(widget.user.uid, feedback);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Abarika! Aw ka lafili donna.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ayiwa! Lafili ma se ka ci: $e')),
                  );
                }
              }
            },
            child: const Text('Ci'),
          ),
        ],
      ),
    );
    feedbackController.dispose();
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
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.feedback, color: Colors.black),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              ),
              tooltip: 'Lafili',
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: _signOut,
              tooltip: 'Ka bɔ',
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(
                            photoURL ?? placeholderImage,
                          ),
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
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      onEditingComplete: updateDisplayName,
                      textAlign: TextAlign.center,
                      controller: controller,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        hintText: "I ka jiracogo tɔgɔ sɛbɛn",
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton.icon(
                          onPressed: _chooseAvatar,
                          icon: const Icon(Icons.person, color: Colors.white),
                          label: const Text(
                            'Ja sugandi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton.icon(
                          onPressed: _deleteAccount,
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text(
                            'Delete Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildStatCard(
                          title: "Dɔnniya",
                          value: "${widget.userData.xp} XP",
                          icon: Icons.star,
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          title: "Kalan waati bɛɛ lajɛlen",
                          value: widget.userData.totalReadingTime.toString(),
                          icon: Icons.timer,
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          title: "Gafew dafara",
                          value: "${widget.userData.completedBooks.length}",
                          icon: Icons.book,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

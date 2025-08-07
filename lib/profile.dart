import 'package:flutter/material.dart';
import 'package:literacy_app/auth.dart';
import 'package:literacy_app/backend_code/user_session_service.dart';
import 'package:literacy_app/feedback.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/widgets/common/unified_app_bar.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';
import 'package:literacy_app/widgets/common/app_widgets.dart';
import 'package:literacy_app/tutorial_service.dart';

class ProfilePage extends StatefulWidget {
  final Users userData;
  final UserSessionService userSession;

  const ProfilePage(
      {super.key, required this.userData, required this.userSession});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController controller;
  bool showSaveButton = false;
  bool isLoading = false;

  // GlobalKeys for tutorial targets
  final GlobalKey _nameInputKey = GlobalKey();
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _authBannerKey = GlobalKey();
  final GlobalKey _avatarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
        text: widget.userData.displayName ?? 'Kalan-folo');
    controller.addListener(_onNameChanged);
    _checkAndShowTutorial();
  }

  Future<void> _checkAndShowTutorial() async {
    if (mounted) {
      // Small delay to ensure UI is rendered, then show tutorial immediately
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted && !TutorialService.isTutorialShowing()) {
          // Check if we should show tutorial
          bool shouldShow = await TutorialService.shouldShowTutorial('profile');
          if (shouldShow) {
            // Additional small delay to ensure scroll positions are settled
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              await TutorialService.showProfileTutorial(
                context,
                nameInputKey: _nameInputKey,
                statsKey: _statsKey,
                authBannerKey: _authBannerKey,
                avatarKey: _avatarKey,
              );
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onNameChanged);
    controller.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (mounted) {
      setState(() {
        showSaveButton = controller.text != widget.userData.displayName &&
            controller.text.isNotEmpty;
      });
    }
  }

  Future updateDisplayName() async {
    widget.userData.displayName = controller.text;
    await widget.userSession.updateUserData(widget.userData);

    if (mounted) {
      setState(() {
        showSaveButton = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jiracogo tɔgɔ kura donna'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    await widget.userSession.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  Future<void> _showAccountCreationDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController =
        TextEditingController(text: widget.userData.displayName);
    final formKey = GlobalKey<FormState>();

    // Focus nodes for field switching
    final nameFocusNode = FocusNode();
    final emailFocusNode = FocusNode();
    final passwordFocusNode = FocusNode();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.lg),
                      topRight: Radius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_rounded,
                        size: 48,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Jatebɔsɛbɛn dabɔ',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Aw ka kunnafoniw mara walasa ka aw ka ɲɛtaa sabati',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),

                // Form content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            focusNode: nameFocusNode,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(emailFocusNode);
                            },
                            decoration: AppDecorations.getInputDecoration(
                              hintText: 'I ka tɔgɔ',
                              prefixIcon: Icons.person,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: emailController,
                            focusNode: emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(passwordFocusNode);
                            },
                            decoration: AppDecorations.getInputDecoration(
                              hintText: 'Imɛli walima telefɔni nimɔrɔ',
                              prefixIcon: Icons.email,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Imɛli walima telefɔni de wajibiyalen don';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: passwordController,
                            focusNode: passwordFocusNode,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              _submitAccountCreation(
                                formKey,
                                emailController,
                                passwordController,
                                nameController,
                              );
                            },
                            decoration: AppDecorations.getInputDecoration(
                              hintText: 'Kɔdi',
                              prefixIcon: Icons.lock,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kɔdi de wajibiyalen don';
                              }
                              if (value.length < 6) {
                                return 'Kɔdi ka kan ka tɛmɛ 6 ye';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadius.lg),
                      bottomRight: Radius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Ka dankari',
                          onPressed: () => Navigator.of(context).pop(),
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Jatebɔsɛbɛn dabɔ',
                          onPressed: () => _submitAccountCreation(
                            formKey,
                            emailController,
                            passwordController,
                            nameController,
                          ),
                          height: 48,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Clean up focus nodes
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
  }

  Future<void> _submitAccountCreation(
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController nameController,
  ) async {
    if (formKey.currentState!.validate()) {
      final result = await widget.userSession.createAccount(
        emailOrPhone: emailController.text.trim(),
        password: passwordController.text,
        displayName:
            nameController.text.isNotEmpty ? nameController.text : null,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor:
              result['success'] ? AppColors.success : AppColors.error,
        ),
      );

      if (result['success'] && mounted) {
        // Don't call setState here as it might cause tab reset
        // The user session change will trigger a rebuild naturally
      }
    }
  }

  Future<void> _showSignInDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Focus nodes for field switching
    final emailFocusNode = FocusNode();
    final passwordFocusNode = FocusNode();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.wisdomTeal.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.lg),
                      topRight: Radius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.login_rounded,
                        size: 48,
                        color: AppColors.wisdomTeal,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'I ka don a kɔnɔ',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.wisdomTeal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Aw ye aw ka jatebɔsɛbɛn kunnafoniw sɛbɛn walasa ka don',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Form content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: emailController,
                            focusNode: emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(passwordFocusNode);
                            },
                            decoration: AppDecorations.getInputDecoration(
                              hintText: 'Imɛli walima telefɔni nimɔrɔ',
                              prefixIcon: Icons.email,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Imɛli walima telefɔni de wajibiyalen don';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: passwordController,
                            focusNode: passwordFocusNode,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              _submitSignIn(
                                formKey,
                                emailController,
                                passwordController,
                              );
                            },
                            decoration: AppDecorations.getInputDecoration(
                              hintText: 'Kɔdi',
                              prefixIcon: Icons.lock,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kɔdi de wajibiyalen don';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadius.lg),
                      bottomRight: Radius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Ka dankari',
                          onPressed: () => Navigator.of(context).pop(),
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: PrimaryButton(
                          text: 'A digi',
                          onPressed: () => _submitSignIn(
                            formKey,
                            emailController,
                            passwordController,
                          ),
                          height: 48,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Clean up focus nodes
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
  }

  Future<void> _submitSignIn(
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) async {
    if (formKey.currentState!.validate()) {
      final result = await widget.userSession.signIn(
        emailOrPhone: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor:
              result['success'] ? AppColors.success : AppColors.error,
        ),
      );

      if (result['success'] && mounted) {
        // Don't call setState here as it might cause tab reset
        // The user session change will trigger a rebuild naturally
      }
    }
  }

  Future<void> _showAccountOptionsDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            'Jatebɔsɛbɛn',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aw ka kunnafoniw mara walasa ka aw ka ɲɛtaa sabati ka baara ka kɛ kɛrɛnkɛrɛnnenya wɛrɛw la.',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Jatebɔsɛbɛn dabɔ',
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showAccountCreationDialog();
                      },
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SecondaryButton(
                      text: 'Don a kɔnɔ',
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showSignInDialog();
                      },
                      height: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSignOutDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Ka bɔ',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          content: Text(
            'I baana i ka jatebɔsɛbɛn bɔ wa? I tɛ se ka segin o la.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
          actions: [
            SecondaryButton(
              text: 'Ka dankari',
              onPressed: () => Navigator.of(context).pop(),
              width: 120,
              height: 48,
            ),
            Container(
              width: 120,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await widget.userSession.signOut();
                    if (mounted) {
                      // Don't call setState here as it might cause tab reset
                      // The user session change will trigger a rebuild naturally
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('I bɔra ka ɲɛ!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  child: Center(
                    child: Text(
                      'Ka bɔ',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Row(
            children: [
              Icon(
                Icons.delete_forever,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Jatebɔsɛbɛn bɔ',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'I baana i ka jatebɔsɛbɛn bɔ wa? O baara ka kɛ kɛrɛnkɛrɛnnenya wɛrɛw la. I tɛ se ka segin o la.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: AppSpacing.lg),
              Form(
                key: formKey,
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    _handleDeleteAccount(passwordController.text, formKey);
                  },
                  decoration: AppDecorations.getInputDecoration(
                    hintText: 'Kɔdi sɛbɛn walasa ka jatebɔsɛbɛn bɔ',
                    prefixIcon: Icons.lock,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kɔdi de wajibiyalen don';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          actions: [
            SecondaryButton(
              text: 'Ka dankari',
              onPressed: () => Navigator.of(context).pop(),
              width: 120,
              height: 48,
            ),
            Container(
              width: 120,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () {
                    _handleDeleteAccount(passwordController.text, formKey);
                    Navigator.of(context).pop();
                  },
                  child: Center(
                    child: Text(
                      'Bɔ',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    // Clean up controller
    //passwordController.dispose();
  }

  Future<void> _handleDeleteAccount(
      String password, GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      // Close dialog first
      //Navigator.of(context).pop();

      try {
        final result = await widget.userSession.deleteAccount(
          password: password,
        );

        if (!mounted) return;

        // Show result message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor:
                result['success'] ? AppColors.success : AppColors.error,
          ),
        );

        // Only navigate if deletion was successful
        if (result['success'] && mounted) {
          // Small delay to ensure SnackBar is shown
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AuthGate()),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fɛn dɔ ma ɲɛ: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Ka makɔnɔ...',
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: UnifiedAppBar(
          title: 'Profil',
          showLogo: false,
          actions: [
            AppBarActionButton(
              icon: Icons.feedback,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              ),
              tooltip: 'Lafili',
            ),
            if (!widget.userSession.isAuthenticated)
              AppBarActionButton(
                icon: Icons.account_circle,
                onPressed: _showAccountOptionsDialog,
                tooltip: 'Jatebɔsɛbɛn',
                backgroundColor: AppColors.accentSurfaceLight,
                iconColor: AppColors.accentOrange,
              ),
            if (widget.userSession.isAuthenticated)
              AppBarActionButton(
                icon: Icons.logout,
                onPressed: _showSignOutDialog,
                tooltip: 'Ka bɔ',
                backgroundColor: AppColors.error.withOpacity(0.1),
                iconColor: AppColors.error,
              ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Profile avatar section
                _buildProfileAvatar(),
                const SizedBox(height: AppSpacing.xl),

                // Name input section
                _buildNameInput(),
                const SizedBox(height: AppSpacing.xl),

                // Authentication status
                if (!widget.userSession.isAuthenticated)
                  _buildAuthenticationBanner(),

                // Sign out section for authenticated users
                if (widget.userSession.isAuthenticated) _buildSignOutSection(),

                // Stats section
                _buildStatsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return AppCard(
      key: _avatarKey,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // App Logo as Profile Picture
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.jpg',
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'I ni ce! 🦉',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'An be kalan kɛrɛnkɛrɛnnenya',
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return AppCard(
      key: _nameInputKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: AppColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'I ka jiracogo tɔgɔ',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller,
            onEditingComplete: updateDisplayName,
            style: AppTextStyles.bodyLarge,
            decoration: AppDecorations.getInputDecoration(
              hintText: "I ka jiracogo tɔgɔ sɛbɛn",
            ),
          ),
          if (showSaveButton) ...[
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              text: 'Mara',
              onPressed: updateDisplayName,
              width: double.infinity,
              icon: Icons.save,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuthenticationBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: InfoBanner(
        key: _authBannerKey,
        title: 'Kalan kɛ tɛmɛnni kɛ',
        message:
            'Aw ye jatebɔsɛbɛn dabɔ walasa ka aw ka ɲɛtaa sabati ka baara ka kɛ kɛrɛnkɛrɛnnenya wɛrɛw la.',
        icon: Icons.info_outline,
        color: AppColors.accentOrange,
        buttonText: 'Jatebɔsɛbɛn dabɔ walima don',
        onButtonPressed: _showAccountOptionsDialog,
      ),
    );
  }

  Widget _buildSignOutSection() {
    // Check if user has a password (authenticated account)
    final hasPassword = widget.userData.password != null &&
        widget.userData.password!.isNotEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.logout,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Jatebɔsɛbɛn',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'I baana i ka jatebɔsɛbɛn bɔ wa? I tɛ se ka segin o la.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.left,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Show both buttons only if user has password
          if (hasPassword) ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        onTap: _showSignOutDialog,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.logout,
                                color: AppColors.pureWhite,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Ka bɔ',
                                style: AppTextStyles.buttonText.copyWith(
                                  color: AppColors.pureWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.error,
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        onTap: _showDeleteAccountDialog,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_forever,
                                color: AppColors.pureWhite,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Bɔ',
                                style: AppTextStyles.buttonText.copyWith(
                                  color: AppColors.pureWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Show only sign out button for users without password
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: _showSignOutDialog,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.logout,
                          color: AppColors.pureWhite,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Ka bɔ',
                          style: AppTextStyles.buttonText.copyWith(
                            color: AppColors.pureWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      key: _statsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'I ka ɲɛtaa jateminɛ',
                style: AppTextStyles.heading3,
              ),
            ],
          ),
        ),
        StatCard(
          title: "Dɔnniya",
          value: "${widget.userData.xp} XP",
          icon: Icons.star,
          color: AppColors.accentOrange,
        ),
        const SizedBox(height: AppSpacing.md),
        StatCard(
          title: "Kalan waati bɛɛ lajɛlen",
          value: "${widget.userData.totalReadingTime} min",
          icon: Icons.timer,
          color: AppColors.wisdomTeal,
        ),
        const SizedBox(height: AppSpacing.md),
        StatCard(
          title: "Gafew dafara",
          value: "${widget.userData.completedBooks.length}",
          icon: Icons.book,
          color: AppColors.success,
        ),
        const SizedBox(height: AppSpacing.md),
        StatCard(
          title: "Gafew bɛɛ kɛɛ la",
          value: "${widget.userData.inProgressBooks.length}",
          icon: Icons.bookmark,
          color: AppColors.bookBlue,
        ),
      ],
    );
  }
}

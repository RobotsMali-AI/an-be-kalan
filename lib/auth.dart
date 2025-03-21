import 'package:firebase_auth/firebase_auth.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/main.dart';
import 'package:flutter/material.dart';
import './models/Users.dart' as users;
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:literacy_app/widgets/customRicheText.dart';
import 'package:literacy_app/widgets/reusableButton.dart';
import 'package:provider/provider.dart';
import 'auth_function.dart';
import 'widgets/customTextFormField.dart';

typedef OAuthSignIn = void Function();

/// The mode of the current auth session, either [AuthMode.login] or [AuthMode.register].
enum AuthMode { login, register }

extension on AuthMode {
  String get label =>
      this == AuthMode.login ? 'I ka don a kɔnɔ' : 'I tɔgɔ sɛbɛnni';
}

/// Entrypoint example for various sign-in flows with Firebase.
class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);
  //static String? appleAuthorizationCode;
  @override
  State<StatefulWidget> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  AuthMode mode = AuthMode.login;

  bool isLoading = false;
  late ApiFirebaseService apiFirebaseService;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  late Map<Buttons, OAuthSignIn> authButtons;

  @override
  void initState() {
    super.initState();
    apiFirebaseService =
        Provider.of<ApiFirebaseService>(context, listen: false);
    authButtons = {
      Buttons.Google: _signInWithGoogle,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SafeArea(
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Add App Logo
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Image.asset(
                              'assets/icon/appIcon.png', // Replace with your logo path
                              height: 100,
                            ),
                          ),
                          Visibility(
                            visible: error.isNotEmpty,
                            child: MaterialBanner(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                              content: SelectableText(
                                error,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      error = '';
                                    });
                                  },
                                  child: const Text(
                                    'Ka bɔ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                              contentTextStyle:
                                  const TextStyle(color: Colors.white),
                              padding: const EdgeInsets.all(10),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              CustomTextFormFieldWidget(
                                controller: emailController,
                                hintText: 'Imɛli',
                                errorText: 'Imɛli de wajibiyalen don',
                                prefixIcon: Icons.email,
                                inputType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                              ),
                              const SizedBox(height: 20),
                              CustomTextFormFieldWidget(
                                  controller: passwordController,
                                  hintText: 'Kɔdi',
                                  errorText: 'Kɔdi de wajibiyalen don',
                                  prefixIcon: Icons.lock,
                                  obscureText: true),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ReusableButton(
                                text: mode.label,
                                onPressed: _emailAndPassword,
                                isLoading: isLoading),
                          ),
                          TextButton(
                            onPressed: () => resetPassword(context),
                            child: const Text(
                              'I ɲinɛna tɔgɔlasɛbɛn kɔ wa?',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                          ),
                          ...authButtons.keys
                              .map(
                                (button) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: isLoading
                                        ? Container(
                                            color: Colors.grey[200],
                                            height: 50,
                                            width: double.infinity,
                                          )
                                        : SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: SignInButton(
                                              button,
                                              onPressed: authButtons[button]!,
                                            ),
                                          ),
                                  ),
                                ),
                              )
                              .toList(),
                          const SizedBox(height: 20),
                          CustomRichetext(
                              text1: mode == AuthMode.login
                                  ? "Yala i tɛ ni jatebɔsɛbɛn ye wa? "
                                  : 'I kɔrɔlen jatebɔsɛbɛn na kaban wa? ',
                              text2: mode == AuthMode.login
                                  ? 'Aw ye aw tɔgɔ sɛbɛn sisan'
                                  : 'A digi walisa ka don',
                              onPressed: () {
                                setState(() {
                                  mode = mode == AuthMode.login
                                      ? AuthMode.register
                                      : AuthMode.login;
                                });
                              }),
                          const SizedBox(height: 10),
                          CustomRichetext(
                              text1: 'Walima ',
                              text2: 'ka t’a fɛ i n’a fɔ dunan',
                              onPressed: _anonymousAuth),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _anonymousAuth() async {
    setIsLoading();

    try {
      await auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      setState(() {
        error = '$e';
      });
    } finally {
      setIsLoading();
    }
  }

  Future<void> _emailAndPassword() async {
    if (formKey.currentState?.validate() ?? false) {
      setIsLoading();
      if (mode == AuthMode.login) {
        try {
          await auth.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
        } on FirebaseAuthException catch (e) {
          setState(() {
            error = '${e.message}';
            setIsLoading();
            //showSnackbar(context, e.message ?? 'An error occurred');
          });
        } catch (e) {
          setState(() {
            error = '$e';
            setIsLoading();
            //showSnackbar(context, e.toString());
          });
        } finally {
          setIsLoading();
        }
      } else if (mode == AuthMode.register) {
        try {
          final userAuth = await auth.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          final user = users.Users(
              uid: userAuth.user!.uid,
              downloadBooks: [],
              xp: 0,
              completedBooks: [],
              favoriteBooks: [],
              inProgressBooks: [],
              totalReadingTime: 0,
              xpLog: []);
          await apiFirebaseService.saveUserData(userAuth.user!.uid, user);
        } on FirebaseAuthException catch (e) {
          setState(() {
            error = '${e.message}';
            setIsLoading();
            //showSnackbar(context, e.message ?? 'An error occurred');
          });
        } catch (e) {
          setState(() {
            error = '$e';
            setIsLoading();
            //showSnackbar(context, e.toString());
          });
        } finally {
          setIsLoading();
        }
      }
      setIsLoading();
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setIsLoading();
      // Trigger the authentication flow
      final googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final googleAuth = await googleUser?.authentication;

      if (googleAuth != null) {
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        await auth.signInWithCredential(credential);
      }
      setIsLoading();
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
        setIsLoading();
        //showSnackbar(context, e.message ?? 'An error occurred');
      });
    } catch (e) {
      setState(() {
        error = '$e';
        setIsLoading();
        //showSnackbar(context, e.toString());
      });
    } finally {
      setIsLoading();
    }
  }
}

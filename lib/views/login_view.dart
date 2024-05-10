import 'package:enote/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Text('Login'),
        ),
        body: FutureBuilder(
            future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            ),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 50,
                        ),
                        TextField(
                          controller: _email,
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                          ),
                        ),
                        TextField(
                          controller: _password,
                          autocorrect: false,
                          enableSuggestions: false,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Enter your password',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              final userCredential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: _email.text,
                                      password: _password.text);
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'invalid-credential') {
                                print('Invalid Credentials');
                              }
                              print(e.message);
                              print(e.code == 'invalid-credential');
                            } catch (e) {
                              print("Something went wronged!");
                            }
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  );
                default:
                  return const Text('Loading...');
              }
            }));
  }
}
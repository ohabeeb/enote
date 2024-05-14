import 'package:enote/constants/routes.dart';
import 'package:enote/helpers/show_error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

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
        title: const Text('Login'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
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
                          email: _email.text, password: _password.text);
                  if (userCredential.user!.emailVerified) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  } else {
                    Navigator.of(context).pushNamed(
                      emailVerificationRoute,
                    );
                  }

                  log(userCredential.toString());
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'invalid-credential') {
                    await showErrorDialog(context, 'Invalid credentials');
                    // log('Invalid Credentials');
                  } else if (e.code == 'network-request-failed') {
                    await showErrorDialog(context, 'No internet connection.');
                  } else {
                    await showErrorDialog(
                        context, 'Something went wronged, please try again.');
                  }
                } catch (e) {
                  log("Something went wronged!");
                }
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Not registered yet? Register here!'),
            )
          ],
        ),
      ),
    );
  }
}

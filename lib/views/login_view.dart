import 'package:enote/constants/routes.dart';
import 'package:enote/helpers/show_error_dialog.dart';
import 'package:enote/services/auth/auth_exceptions.dart';
import 'package:enote/services/auth/auth_service.dart';
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
                  final userCredential = await AuthService.firebase()
                      .logIn(email: _email.text, password: _password.text);
                  if (userCredential.isEmailVerified) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  } else {
                    Navigator.of(context).pushNamed(
                      emailVerificationRoute,
                    );
                  }

                  log(userCredential.toString());
                } on WrongPasswordAuthException {
                  await showErrorDialog(context, 'Wrong password');
                } on UserNotFoundAuthException {
                  await showErrorDialog(context, 'User not found');
                } on GenericAuthException {
                  await showErrorDialog(
                      context, 'Authentication error! Please try again.');
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

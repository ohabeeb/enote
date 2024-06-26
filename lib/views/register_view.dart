import 'package:enote/constants/routes.dart';
import 'package:enote/helpers/show_error_dialog.dart';
import 'package:enote/services/auth/auth_exceptions.dart';
import 'package:enote/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    // TODO: implement initState
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _email,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "Enter your email",
              ),
            ),
            TextField(
              controller: _password,
              autocorrect: false,
              enableSuggestions: false,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Enter your password",
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;

                try {
                  await AuthService.firebase().createUser(
                    email: email,
                    password: password,
                  );

                  await AuthService.firebase().sendEmailVerification();
                  // final user = FirebaseAuth.instance.currentUser;
                  // await user?.sendEmailVerification();

                  Navigator.of(context).pushNamed(emailVerificationRoute);
                } on EmailAlreadyInUsedAuthException {
                  // if (e.code == 'email-already-in-use') {
                  await showErrorDialog(context, 'Email already in use');
                } on InvalidEmailAuthException {
                  await showErrorDialog(context, 'Invalid email address');
                } on WeakPasswordAuthException {
                  await showErrorDialog(context, 'Your password is weak');
                } on GenericAuthException {
                  await showErrorDialog(
                      context, 'Error creating account! Please try again');
                } catch (e) {
                  log(e.toString());
                }
              },
              child: const Text('Register'),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: const Text('Already register? Login here!'))
          ],
        ),
      ),
    );
  }
}

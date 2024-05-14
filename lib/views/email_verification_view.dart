import 'package:enote/constants/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Please verify your email address',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
                'Email verification link as been sent to ${user!.email.toString()}',
                textAlign: TextAlign.center),
            TextButton(
                onPressed: () async {
                  await user?.sendEmailVerification();
                },
                child:
                    const Text("Click here if you don't received email link.")),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text('Restart'),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:enote/constants/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<MenuActions>(onSelected: (value) async {
            switch (value) {
              case MenuActions.logout:
                // TODO: Handle this case.
                final shouldLogout = await showLogoutDialog(context);
                if (shouldLogout) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                }
                break;
              case MenuActions.profile:
              // TODO: Handle this case.
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuActions>(
                value: MenuActions.logout,
                child: Text('Logout'),
              ),
              PopupMenuItem<MenuActions>(
                value: MenuActions.profile,
                child: Text('Profile'),
              ),
            ];
          }),
        ],
      ),
    );
  }
}

enum MenuActions {
  logout,
  profile,
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes')),
          ],
        );
      }).then((value) => value ?? false);
}

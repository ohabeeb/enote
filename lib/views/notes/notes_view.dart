import 'package:enote/constants/routes.dart';
import 'package:enote/enums/menu_action.dart';
import 'package:enote/services/auth/auth_service.dart';
import 'package:enote/services/crud/notes_service.dart';
import 'package:flutter/material.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NoteService _noteService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    // TODO: implement initState
    _noteService = NoteService();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _noteService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Notes'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () => {
              Navigator.of(context)
                  .pushNamed(newNoteRoute)
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
          PopupMenuButton<MenuActions>(onSelected: (value) async {
            switch (value) {
              case MenuActions.logout:
                // TODO: Handle this case.
                final shouldLogout = await showLogoutDialog(context);
                if (shouldLogout) {
                  await AuthService.firebase().logOut();
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _noteService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                // TODO: Handle this case.
                return StreamBuilder(
                  stream: _noteService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        return const Text('Waiting for all notes...');

                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
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

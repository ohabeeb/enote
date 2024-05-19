import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

class DatabaseAlreadyOpenException implements Exception {}

class DatabaseIsNotOpenException implements Exception {}

class UnableToGetDocumentsDirectoryException implements Exception {}

class CouldNotDeleteUser implements Exception {}

class UserAlreadyExists implements Exception {}

class CouldNotFindUser implements Exception {}

class CouldNotDeleteNote implements Exception {}

class CouldNotFindNote implements Exception {}

class CouldNotUpdateNote implements Exception {}

class NoteService {
  Database? _database;
  Database _getDatabaseOrThrow() {
    final database = _database;
    if (database == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return database;
    }
  }

  Future<void> open() async {
    if (_database != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final database = await openDatabase(dbPath);
      _database = database;

      await database.execute(createUserTable);

      await database.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> close() async {
    final database = _database;
    if (database == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await database.close();
      _database = null;
    }
  }

  // Note CRUD
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final database = _getDatabaseOrThrow();
    // make sure owner exist in the Note
    final existingUser = await getUser(email: owner.email);
    if (existingUser != owner) {
      throw CouldNotFindUser();
    }
    const noteContent = '';
    final noteId = await database.insert(noteTable, {
      userIdColumn: owner.id,
      contentColumn: noteContent,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      content: noteContent,
      isSyncedWithCloud: true,
    );
    return note;
  }

  Future<DatabaseNote> getNoteById({required int id}) async {
    final database = _getDatabaseOrThrow();
    final notes = await database.query(
      noteTable,
      limit: 1,
      where: 'user_id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    }
    return DatabaseNote.fromRow(notes.first);
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final database = _getDatabaseOrThrow();
    final notes = await database.query(noteTable);
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    }
    return notes.map((e) => DatabaseNote.fromRow(e));
  }

  Future<DatabaseNote> updateNoteById(
      {required DatabaseNote note, required String text}) async {
    final database = _getDatabaseOrThrow();
    await getNoteById(id: note.id);
    final updateResult = await database.update(noteTable, {
      contentColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updateResult == 0) {
      throw CouldNotUpdateNote();
    }
    return await getNoteById(id: note.id);
  }

  Future<void> deleteNote({required int id}) async {
    final database = _getDatabaseOrThrow();
    final deletedCount = await database.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteNote();
    }
  }

  Future<int> deleteAllNotes() async {
    final database = _getDatabaseOrThrow();
    return await database.delete(noteTable);
  }

  // User CRUD
  Future<DatabaseUser> createUser({required String email}) async {
    final database = _getDatabaseOrThrow();
    final result = await database.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await database.insert(
      userTable,
      {emailColumn: email.toLowerCase()},
    );
    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final database = _getDatabaseOrThrow();
    final result = await database.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUser();
    }
    return DatabaseUser.fromRow(result.first);
  }

  Future<void> deleteUser({required String email}) async {
    final database = _getDatabaseOrThrow();
    final deletedCount = await database.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map['id'] as int,
        email = map['email'] as String;

  @override
  String toString() => 'Person ID $id, email $email';

  @override
  bool operator ==(covariant DatabaseUser other) {
    // TODO: implement ==
    return id == other.id;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String content;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.content,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        content = map[contentColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID: $id userId = $userId, content = $content, isSyncedWithCloud $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseNote other) {
    // TODO: implement ==
    return id == other.id;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';

const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const createUserTable = '''
      CREATE TABLE IF NOT EXISTS "user" (
    	       "id"	INTEGER NOT NULL UNIQUE,
    	       "email"	TEXT NOT NULL UNIQUE,
    	       PRIMARY KEY("id" AUTOINCREMENT)
      ); ''';

const noteTable = 'note';
// const idColumn = 'id';
const userIdColumn = 'user_id';
const contentColumn = 'content';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createNoteTable = '''
      CREATE TABLE IF NOT EXISTS "note" (
          "id"	INTEGER NOT NULL UNIQUE,
          "user_id"	INTEGER NOT NULL,
          "content"	TEXT,
          "is_sync_with_cloud"	INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY("user_id") REFERENCES "user"("id"),
          PRIMARY KEY("id" AUTOINCREMENT)
        );''';

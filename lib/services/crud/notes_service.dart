import 'dart:async';

import 'package:enote/services/crud/crud_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

class NoteService {
  Database? _database;

  static final NoteService _shared = NoteService._sharedInstance();
  NoteService._sharedInstance();
  factory NoteService() => _shared;

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

      await _catchNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseIsNotOpenException {
      // throw nothing
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

  List<DatabaseNote> _notes = [];

  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _catchNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  // Note CRUD
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
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

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
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
    final note = DatabaseNote.fromRow(notes.first);
    _notes.removeWhere((note) => note.id == id);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final database = _getDatabaseOrThrow();
    final notes = await database.query(noteTable);
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    }
    return notes.map((e) => DatabaseNote.fromRow(e));
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await _ensureDbIsOpen();
    final database = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updateResult = await database.update(noteTable, {
      contentColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updateResult == 0) {
      throw CouldNotUpdateNote();
    }
    final updatedNote = await getNote(id: note.id);
    _notes.removeWhere((element) => element.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final database = _getDatabaseOrThrow();
    final deletedCount = await database.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final database = _getDatabaseOrThrow();
    final numbersOfDeletion = await database.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numbersOfDeletion;
  }

  // User CRUD
  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
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
    await _ensureDbIsOpen();
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
    await _ensureDbIsOpen();
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

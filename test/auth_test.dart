// import 'package:enote/services/auth/auth_exceptions.dart';
// import 'package:enote/services/auth/auth_user.dart';
// import 'package:enote/services/auth/auth_provider.dart';
//
// void main() {}
//
// class NotInitializedException implements Exception {}
//
// class MockAuthProvider implements AuthProvider {
//   AuthUser? _user;
//   var _isInitialized = false;
//   bool get isInitialized => _isInitialized;
//
//   @override
//   Future<AuthUser> createUser(
//       {required String email, required String password}) async {
//     // TODO: implement createUser
//     if (!isInitialized) throw NotInitializedException();
//     await Future.delayed(const Duration(seconds: 1));
//     return logIn(email: email, password: password);
//   }
//
//   @override
//   // TODO: implement currentUser
//   AuthUser? get currentUser => _user;
//
//   @override
//   Future<void> initialize() async {
//     // TODO: implement initialize
//     await Future.delayed(const Duration(seconds: 1));
//     _isInitialized = true;
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<AuthUser> logIn({required String email, required String password}) {
//     // TODO: implement logIn
//     if (!_isInitialized) throw NotInitializedException();
//     if (email == 'foot@bar.com') throw UserNotFoundAuthException();
//     if (password == 'foo') throw WrongPasswordAuthException();
//     const user = AuthUser(isEmailVerified: false);
//     _user = user;
//     return Future.value(user);
//   }
//
//   @override
//   Future<void> logOut() async {
//     // TODO: implement logOut
//     if (!_isInitialized) throw NotInitializedException();
//     if (_user == null) throw UserNotFoundAuthException();
//     await Future.delayed(const Duration(seconds: 1));
//     _user = null;
//   }
//
//   @override
//   Future<void> sendEmailVerification() {
//     if (!_isInitialized) throw NotInitializedException();
//     final user = _user;
//     if (user == null) throw UserNotFoundAuthException();
//     const newUser = AuthUser(isEmailVerified: true);
//     _user = newUser;
//     // TODO: implement sendEmailVerification
//     throw UnimplementedError();
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Поточний користувач
  User? get currentUser => _auth.currentUser;

  // Потік стану автентифікації
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided.';
      }
      throw 'Sign-in failed: ${e.message}';
    }
  }

  Future<User?> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null && displayName != null) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw 'The email address is already in use.';
      } else if (e.code == 'weak-password') {
        throw 'The password is too weak.';
      }
      throw 'Sign-up failed: ${e.message}';
    }
  }

  // Вихід із системи
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

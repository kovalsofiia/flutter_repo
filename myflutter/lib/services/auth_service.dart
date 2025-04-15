import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Поточний користувач
  User? get currentUser => _auth.currentUser;

  // Потік стану автентифікації
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Реєстрація за email і паролем
  Future<User?> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        // Задати displayName
        if (displayName != null) {
          await userCredential.user!.updateDisplayName(displayName);
          await userCredential.user!.reload();
        }
        // Створити профіль у Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'displayName': displayName,
          'isAdmin': false, // За замовчуванням не адмін
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return userCredential.user;
    } catch (e) {
      print('Sign-Up Error: $e');
      return null;
    }
  }

  // Логін за email і паролем
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Sign-In Error: $e');
      return null;
    }
  }

  // Вихід із системи
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Перевірка, чи є користувач адміністратором
  Future<bool> isAdmin(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists && (doc.data()?['isAdmin'] ?? false);
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
}

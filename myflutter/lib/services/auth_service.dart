import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myflutter/models/AppUser.dart'; // Імпорт моделі

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
        // Створити профіль у Firestore за допомогою моделі AppUser
        final appUser = AppUser(
          uid: userCredential.user!.uid,
          email: email,
          displayName: displayName,
          isAdmin: false,
        );
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(appUser.toFirestore());
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
      if (doc.exists) {
        final appUser = AppUser.fromFirestore(doc);
        return appUser.isAdmin;
      }
      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Отримання профілю користувача
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/app_user.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  // Correos autorizados con privilegios de administración
  static const List<String> authorizedAdminEmails = [
    'omanjrvasquez@gmail.com',
    'omanvasquez@gmail.com',
    'omanpago@gmail.com',
  ];

  AuthRepository({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      final email = user.email?.toLowerCase() ?? '';
      final isAdmin = authorizedAdminEmails.contains(email);
      return AppUser.fromFirebase(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        isAdmin: isAdmin,
      );
    });
  }

  AppUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    final email = user.email?.toLowerCase() ?? '';
    final isAdmin = authorizedAdminEmails.contains(email);
    return AppUser.fromFirebase(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAdmin: isAdmin,
    );
  }

  Future<AppUser> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        userCredential = await _firebaseAuth.signInWithProvider(googleProvider);
      }

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('No se pudo obtener información del usuario autenticado.');
      }

      final email = user.email?.toLowerCase() ?? '';
      final isAdmin = authorizedAdminEmails.contains(email);

      return AppUser.fromFirebase(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        isAdmin: isAdmin,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Error al iniciar sesión con Google: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Error al cerrar sesión: ${e.toString()}');
    }
  }
}

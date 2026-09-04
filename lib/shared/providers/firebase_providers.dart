import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/clients/data/clients_repository.dart';
import '../../features/kiosk_signature/data/signature_repository.dart';
import '../../features/photos/data/photo_repository.dart';
import '../../features/sessions/data/sessions_repository.dart';

// ==========================================
// Firebase SDK Direct Instances
// ==========================================

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// ==========================================
// Repositories Dependency Injection
// ==========================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) {
  return ClientsRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  return SessionsRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

final signatureRepositoryProvider = Provider<SignatureRepository>((ref) {
  return SignatureRepository(
    storage: ref.watch(firebaseStorageProvider),
  );
});

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepository(
    storage: ref.watch(firebaseStorageProvider),
  );
});

// ==========================================
// Reactive Auth Stream Providers
// ==========================================

final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

final isUserAdminProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user?.isAdmin ?? false,
    orElse: () => false,
  );
});

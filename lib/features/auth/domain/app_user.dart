/// Modelo de usuario autenticado mediante Google Sign-In.
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isAdmin;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isAdmin = false,
  });

  factory AppUser.fromFirebase({
    required String uid,
    required String? email,
    required String? displayName,
    String? photoUrl,
    bool isAdmin = false,
  }) {
    return AppUser(
      uid: uid,
      email: email ?? '',
      displayName: displayName ?? 'Administrador',
      photoUrl: photoUrl,
      isAdmin: isAdmin,
    );
  }
}

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../domain/session_model.dart';

/// Stream de sesiones de un cliente puntual
final clientSessionsProvider =
    StreamProvider.autoDispose.family<List<SessionModel>, String>((ref, clientId) {
  final repo = ref.watch(sessionsRepositoryProvider);
  return repo.streamSessionsByClient(clientId);
});

/// Stream de sesiones recientes del estudio
final recentSessionsProvider = StreamProvider.autoDispose<List<SessionModel>>((ref) {
  final repo = ref.watch(sessionsRepositoryProvider);
  return repo.streamRecentSessions();
});

/// Controlador para crear y gestionar sesiones
final sessionsControllerProvider =
    AsyncNotifierProvider.autoDispose<SessionsController, void>(SessionsController.new);

class SessionsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<String?> createSession(SessionModel session) async {
    state = const AsyncValue.loading();
    String? createdId;
    state = await AsyncValue.guard(() async {
      createdId = await ref.read(sessionsRepositoryProvider).createSession(session);
    });
    return createdId;
  }

  Future<void> attachSignature({
    required String sessionId,
    required String signatureUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(sessionsRepositoryProvider).updateSignatureUrl(sessionId, signatureUrl);
    });
  }

  Future<void> attachPhoto({
    required String sessionId,
    required String photoUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(sessionsRepositoryProvider).addPhotoUrl(sessionId, photoUrl);
    });
  }
}

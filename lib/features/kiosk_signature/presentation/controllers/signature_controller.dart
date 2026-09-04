import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/firebase_providers.dart';

final signatureControllerProvider =
    AsyncNotifierProvider.autoDispose<SignatureController, String?>(SignatureController.new);

class SignatureController extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() {
    return null;
  }

  Future<String?> saveAndUploadSignature({
    required String clientId,
    required String sessionId,
    required Uint8List rawPngBytes,
  }) async {
    state = const AsyncValue.loading();
    String? downloadUrl;
    state = await AsyncValue.guard(() async {
      downloadUrl = await ref.read(signatureRepositoryProvider).uploadSignature(
            clientId: clientId,
            sessionId: sessionId,
            rawPngBytes: rawPngBytes,
          );

      // Asociar la firma a la sesión en Firestore
      if (downloadUrl != null) {
        await ref.read(sessionsRepositoryProvider).updateSignatureUrl(sessionId, downloadUrl!);
      }
      return downloadUrl;
    });
    return downloadUrl;
  }
}

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/firebase_providers.dart';

final photoUploadControllerProvider =
    AsyncNotifierProvider.autoDispose<PhotoUploadController, String?>(PhotoUploadController.new);

class PhotoUploadController extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() {
    return null;
  }

  Future<String?> uploadAndAttachPhoto({
    required String clientId,
    required String sessionId,
    required Uint8List rawBytes,
    required String label, // 'antes', 'despues', etc.
  }) async {
    state = const AsyncValue.loading();
    String? downloadUrl;
    state = await AsyncValue.guard(() async {
      downloadUrl = await ref.read(photoRepositoryProvider).uploadSessionPhoto(
            clientId: clientId,
            sessionId: sessionId,
            rawBytes: rawBytes,
            label: label,
          );

      // Asociar la foto al array urls_fotos de la sesión
      if (downloadUrl != null) {
        await ref.read(sessionsRepositoryProvider).addPhotoUrl(sessionId, downloadUrl!);
      }
      return downloadUrl;
    });
    return downloadUrl;
  }
}

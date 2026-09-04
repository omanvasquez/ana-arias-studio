import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../domain/client_model.dart';

/// Stream reactivo de clientes para alimentar la UI
final clientsListProvider = StreamProvider.autoDispose<List<ClientModel>>((ref) {
  final repo = ref.watch(clientsRepositoryProvider);
  return repo.streamClients();
});

/// Proveedor para obtener un cliente específico por su ID
final clientDetailProvider = FutureProvider.autoDispose.family<ClientModel?, String>((ref, clientId) {
  final repo = ref.watch(clientsRepositoryProvider);
  return repo.getClientById(clientId);
});

/// Controlador para acciones de creación y actualización de clientes
final clientsControllerProvider =
    AsyncNotifierProvider.autoDispose<ClientsController, void>(ClientsController.new);

class ClientsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<String?> createClient({
    required String nombre,
    required String telefono,
    required String email,
    required Map<String, bool> alertasMedicas,
  }) async {
    state = const AsyncValue.loading();
    String? createdId;
    state = await AsyncValue.guard(() async {
      createdId = await ref.read(clientsRepositoryProvider).createClient(
            nombre: nombre,
            telefono: telefono,
            email: email,
            alertasMedicas: alertasMedicas,
          );
    });
    return createdId;
  }

  Future<void> updateMedicalAlerts({
    required String clientId,
    required Map<String, bool> alertas,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(clientsRepositoryProvider).updateMedicalAlerts(clientId, alertas);
    });
  }
}

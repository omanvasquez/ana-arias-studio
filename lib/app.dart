import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/firebase_providers.dart';

/// Aplicación principal PWA Ana Arias Studio.
/// Configurada con Riverpod y el tema corporativo estricto.
class AnaAriasStudioApp extends ConsumerWidget {
  const AnaAriasStudioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Ana Arias Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _BaseProjectReadyView(),
    );
  }
}

/// Vista provisional de confirmación de inicialización base y conexión.
/// No incluye pantallas de negocio definitivas según la instrucción estricta:
/// "No programes pantallas todavía".
class _BaseProjectReadyView extends ConsumerWidget {
  const _BaseProjectReadyView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ana Arias Studio'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const Box480Constraints(),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Proyecto Base Configurado',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Flutter PWA inicializado con arquitectura Riverpod (Feature-First) y enlace con Firebase preparado.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      const Icon(Icons.cloud_done_outlined, size: 18, color: AppColors.textSecondary),
                      Text(
                        'Estado de Auth: ${authState.isLoading ? "Conectando..." : (authState.value != null ? "Autenticado" : "Listo para login")}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Box480Constraints extends BoxConstraints {
  const Box480Constraints()
      : super(
          maxWidth: 480,
          minWidth: 280,
        );
}

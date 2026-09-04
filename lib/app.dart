import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/views/login_view.dart';
import 'features/auth/presentation/views/unauthorized_view.dart';
import 'features/dashboard/presentation/views/dashboard_view.dart';
import 'shared/providers/firebase_providers.dart';

/// Aplicación principal PWA Ana Arias Studio.
/// Control de acceso exclusivo para la administradora (omanpago@gmail.com).
class AnaAriasStudioApp extends ConsumerWidget {
  const AnaAriasStudioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Ana Arias Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginView();
        }

        // Si el usuario no es la cuenta administradora autorizada
        if (!user.isAdmin) {
          return UnauthorizedView(userEmail: user.email.isNotEmpty ? user.email : 'Desconocido');
        }

        // Usuario administrador verificado
        return const DashboardView();
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => const LoginView(),
    );
  }
}

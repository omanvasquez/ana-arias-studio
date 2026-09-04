import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ana_arias_studio/core/constants/app_colors.dart';
import 'package:ana_arias_studio/features/clients/presentation/controllers/clients_controller.dart';
import 'package:ana_arias_studio/features/sessions/presentation/controllers/sessions_controller.dart';
import 'package:ana_arias_studio/features/sessions/presentation/views/session_detail_view.dart';
import 'package:ana_arias_studio/features/sessions/presentation/views/session_form_dialog.dart';

class SessionsListView extends ConsumerWidget {
  const SessionsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(recentSessionsProvider);
    final dateFormat = DateFormat('dd/MM/yyyy · hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agenda y Sesiones Recientes',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Historial cronológico de citas de tratamiento',
                      style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => const SessionFormDialog(),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nueva Cita'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 52, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          Text(
                            'No hay citas registradas en la agenda',
                            style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Agende la primera sesión seleccionando un cliente registrado.',
                            style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => const SessionFormDialog(),
                              );
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Agendar Primera Sesión'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: sessions.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final session = sessions[i];
                    final clientAsync = ref.watch(clientDetailProvider(session.idCliente));

                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => SessionDetailView(
                                session: session,
                                client: clientAsync.value,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.spa_outlined, color: AppColors.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          session.tipoTratamiento,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          dateFormat.format(session.fechaCita),
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                                        const SizedBox(width: 6),
                                        Text(
                                          clientAsync.when(
                                            data: (c) => c?.nombre ?? 'Cliente no encontrado',
                                            loading: () => 'Cargando cliente...',
                                            error: (e, s) => 'Error al cargar',
                                          ),
                                          style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: session.hasSignature
                                                ? AppColors.success.withValues(alpha: 0.1)
                                                : AppColors.alertBackground,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            session.hasSignature ? 'Firma OK' : 'Firma Pendiente',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: session.hasSignature
                                                  ? AppColors.success
                                                  : AppColors.alertPureRed,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${session.urlsFotos.length} fotos',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 11,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

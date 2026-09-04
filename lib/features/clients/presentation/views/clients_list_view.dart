import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ana_arias_studio/core/constants/app_colors.dart';
import 'package:ana_arias_studio/features/clients/domain/medical_alert_model.dart';
import 'package:ana_arias_studio/features/clients/presentation/controllers/clients_controller.dart';
import 'package:ana_arias_studio/features/clients/presentation/views/client_detail_view.dart';
import 'package:ana_arias_studio/features/clients/presentation/views/client_form_dialog.dart';

class ClientsListView extends ConsumerStatefulWidget {
  const ClientsListView({super.key});

  @override
  ConsumerState<ClientsListView> createState() => _ClientsListViewState();
}

class _ClientsListViewState extends ConsumerState<ClientsListView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
                    decoration: InputDecoration(
                      hintText: 'Buscar cliente por nombre, teléfono o correo...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => const ClientFormDialog(),
                    );
                  },
                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                  label: const Text('Nuevo Cliente'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: clientsAsync.when(
              data: (clients) {
                final filtered = clients.where((c) {
                  if (_searchQuery.isEmpty) return true;
                  return c.nombre.toLowerCase().contains(_searchQuery) ||
                      c.telefono.toLowerCase().contains(_searchQuery) ||
                      c.email.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No hay clientes registrados aún'
                                : 'No se encontraron clientes con "$_searchQuery"',
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Comienza registrando la primera ficha de cliente.'
                                : 'Verifica el término de búsqueda o registra un nuevo cliente.',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => const ClientFormDialog(),
                                );
                              },
                              child: const Text('Registrar Primer Cliente'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: filtered.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final client = filtered[i];
                    final hasAlerts = client.hasActiveAlerts;

                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ClientDetailView(client: client),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: hasAlerts ? AppColors.alertBackground : AppColors.surfaceMuted,
                                child: Text(
                                  client.nombre.isNotEmpty ? client.nombre.trim()[0].toUpperCase() : '?',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    color: hasAlerts ? AppColors.alertPureRed : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            client.nombre,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (hasAlerts)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.alertBackground,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppColors.alertBorder),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.warning_amber_rounded,
                                                    size: 14, color: AppColors.alertPureRed),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'ALERTA MÉDICA',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.alertPureRed,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                                        const SizedBox(width: 6),
                                        Text(
                                          client.telefono,
                                          style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                        if (client.email.isNotEmpty) ...[
                                          const SizedBox(width: 16),
                                          const Icon(Icons.email_outlined, size: 14, color: AppColors.textMuted),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              client.email,
                                              style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (hasAlerts) ...[
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: client.activeAlertKeys.map((key) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.alertBackground,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              MedicalAlertKeys.getLabel(key),
                                              style: GoogleFonts.montserrat(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.alertPureRed,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
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
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error al cargar clientes: $err',
                    style: GoogleFonts.montserrat(color: AppColors.alertPureRed),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

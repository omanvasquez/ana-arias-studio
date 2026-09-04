import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ana_arias_studio/core/constants/app_colors.dart';
import 'package:ana_arias_studio/features/photos/presentation/controllers/photo_controller.dart';

class PhotoUploadSheet extends ConsumerStatefulWidget {
  final String clientId;
  final String sessionId;

  const PhotoUploadSheet({
    super.key,
    required this.clientId,
    required this.sessionId,
  });

  static Future<String?> show(BuildContext context, {required String clientId, required String sessionId}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => PhotoUploadSheet(clientId: clientId, sessionId: sessionId),
    );
  }

  @override
  ConsumerState<PhotoUploadSheet> createState() => _PhotoUploadSheetState();
}

class _PhotoUploadSheetState extends ConsumerState<PhotoUploadSheet> {
  final ImagePicker _picker = ImagePicker();
  String _selectedLabel = 'antes';
  bool _isUploading = false;
  String? _statusText;

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (file == null) return;

      setState(() {
        _isUploading = true;
        _statusText = 'Comprimiendo imagen en el dispositivo (< 500 KB)...';
      });

      final rawBytes = await file.readAsBytes();

      setState(() {
        _statusText = 'Subiendo a Firebase Storage...';
      });

      final downloadUrl = await ref.read(photoUploadControllerProvider.notifier).uploadAndAttachPhoto(
            clientId: widget.clientId,
            sessionId: widget.sessionId,
            rawBytes: rawBytes,
            label: _selectedLabel,
          );

      if (mounted) {
        Navigator.of(context).pop(downloadUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fotografía comprimida y adjuntada exitosamente a la sesión.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _statusText = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir fotografía: ${e.toString()}'),
            backgroundColor: AppColors.alertPureRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Adjuntar Fotografía de Tratamiento',
            style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Compresión automática en el cliente (Meta < 500 KB). Protección de cuota Spark.',
            style: GoogleFonts.montserrat(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            'TIPO DE FOTOGRAFÍA',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'antes', label: Text('Antes')),
              ButtonSegment(value: 'despues', label: Text('Después')),
              ButtonSegment(value: 'detalle', label: Text('Detalle')),
            ],
            selected: {_selectedLabel},
            onSelectionChanged: (set) => setState(() => _selectedLabel = set.first),
          ),
          const SizedBox(height: 24),
          if (_isUploading) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    _statusText ?? 'Procesando...',
                    style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickAndUpload(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Cámara'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickAndUpload(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galería / Archivo'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

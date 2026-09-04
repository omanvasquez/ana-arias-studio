import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ana_arias_studio/core/constants/app_colors.dart';
import 'package:ana_arias_studio/features/kiosk_signature/presentation/controllers/signature_controller.dart';

class KioskSignatureView extends ConsumerStatefulWidget {
  final String clientId;
  final String clientName;
  final String sessionId;
  final String treatmentName;

  const KioskSignatureView({
    super.key,
    required this.clientId,
    required this.clientName,
    required this.sessionId,
    required this.treatmentName,
  });

  @override
  ConsumerState<KioskSignatureView> createState() => _KioskSignatureViewState();
}

class _KioskSignatureViewState extends ConsumerState<KioskSignatureView> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  final GlobalKey _canvasKey = GlobalKey();
  bool _isSaving = false;

  bool get _hasSignature => _strokes.isNotEmpty || _currentStroke.isNotEmpty;

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
    });
  }

  Future<Uint8List?> _exportSignaturePng(Size size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.5
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    final allStrokes = [..._strokes];
    if (_currentStroke.isNotEmpty) allStrokes.add(_currentStroke);

    for (final stroke in allStrokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 2.0, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
      } else {
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _submitSignature() async {
    if (!_hasSignature) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, dibuje su firma en el recuadro antes de aceptar.'),
          backgroundColor: AppColors.alertPureRed,
        ),
      );
      return;
    }

    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    setState(() => _isSaving = true);

    try {
      final pngBytes = await _exportSignaturePng(renderBox.size);
      if (pngBytes == null) throw Exception('No se pudo procesar el lienzo de firma.');

      final downloadUrl = await ref.read(signatureControllerProvider.notifier).saveAndUploadSignature(
            clientId: widget.clientId,
            sessionId: widget.sessionId,
            rawPngBytes: pngBytes,
          );

      if (mounted) {
        Navigator.of(context).pop(downloadUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firma registrada y anexada a la sesión exitosamente.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar la firma: ${e.toString()}'),
            backgroundColor: AppColors.alertPureRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: AppColors.surface,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'MODO KIOSCO',
                                style: GoogleFonts.montserrat(
                                  color: AppColors.onPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Consentimiento Digital',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.montserrat(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Yo, ${widget.clientName}, declaro haber sido informada(o) del procedimiento de ${widget.treatmentName}, sus cuidados posteriores y confirmo la veracidad de mi ficha médica en Ana Arias Studio.',
                        style: GoogleFonts.montserrat(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    key: _canvasKey,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 40,
                          right: 40,
                          bottom: 70,
                          child: Container(
                            height: 1,
                            color: AppColors.border,
                          ),
                        ),
                        Positioned(
                          left: 40,
                          bottom: 48,
                          child: Text(
                            'Firme sobre la línea',
                            style: GoogleFonts.montserrat(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ),
                        GestureDetector(
                          onPanStart: (details) {
                            if (_isSaving) return;
                            setState(() {
                              _currentStroke = [details.localPosition];
                            });
                          },
                          onPanUpdate: (details) {
                            if (_isSaving) return;
                            setState(() {
                              _currentStroke.add(details.localPosition);
                            });
                          },
                          onPanEnd: (details) {
                            if (_isSaving) return;
                            setState(() {
                              _strokes.add(List.from(_currentStroke));
                              _currentStroke.clear();
                            });
                          },
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _SignatureCanvasPainter(
                              strokes: _strokes,
                              currentStroke: _currentStroke,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: AppColors.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: (_isSaving || !_hasSignature) ? null : _clear,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Limpiar Lienzo'),
                    ),
                    ElevatedButton.icon(
                      onPressed: (_isSaving || !_hasSignature) ? null : _submitSignature,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                            )
                          : const Icon(Icons.check, size: 20),
                      label: Text(_isSaving ? 'Guardando...' : 'Aceptar y Guardar Firma'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignatureCanvasPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _SignatureCanvasPainter({
    required this.strokes,
    required this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.5
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    final allStrokes = [...strokes];
    if (currentStroke.isNotEmpty) allStrokes.add(currentStroke);

    for (final stroke in allStrokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 2.0, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
      } else {
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignatureCanvasPainter oldDelegate) => true;
}

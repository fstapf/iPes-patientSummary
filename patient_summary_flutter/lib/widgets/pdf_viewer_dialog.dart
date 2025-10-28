import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../constants/app_colors.dart';
import 'pdf_viewer_web.dart' if (dart.library.io) 'pdf_viewer_native.dart';

/// Dialog com visualizador de PDF e controles de zoom
class PdfViewerDialog extends StatefulWidget {
  final Uint8List pdfBytes;
  final String title;

  const PdfViewerDialog({
    super.key,
    required this.pdfBytes,
    required this.title,
  });

  @override
  State<PdfViewerDialog> createState() => _PdfViewerDialogState();
}

class _PdfViewerDialogState extends State<PdfViewerDialog> {
  final PdfViewerController _pdfController = PdfViewerController();

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    print('📊 Building PDF viewer dialog - ${widget.pdfBytes.length} bytes');

    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.9,
          maxHeight: size.height * 0.9,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Cabeçalho com controles
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Fechar',
                ),
              ],
            ),
            const Divider(),
            // Visualizador de PDF
            Expanded(
              child: PdfViewerWidget(
                pdfBytes: widget.pdfBytes,
                controller: _pdfController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

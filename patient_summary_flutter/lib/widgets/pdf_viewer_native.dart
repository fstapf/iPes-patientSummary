import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';

/// Visualizador de PDF para Windows
/// Mostra preview e permite abrir no navegador com zoom nativo
class PdfViewerWidget extends StatefulWidget {
  final Uint8List pdfBytes;
  final PdfViewerController controller;

  const PdfViewerWidget({
    super.key,
    required this.pdfBytes,
    required this.controller,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  String? _pdfPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _savePdfToTemp();
  }

  Future<void> _savePdfToTemp() async {
    try {
      final tempDir = await getTemporaryDirectory();

      // Criar uma pasta específica para PDFs
      final pdfDir = Directory('${tempDir.path}/pdf_viewer');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }

      final file = File('${pdfDir.path}/document_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(widget.pdfBytes);

      if (mounted) {
        setState(() {
          _pdfPath = file.path;
          _isLoading = false;
        });
      }

      print('📄 PDF salvo em: ${file.path}');
    } catch (e) {
      print('❌ Erro ao salvar PDF: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openInBrowser() async {
    if (_pdfPath == null) return;

    try {
      final uri = Uri.file(_pdfPath!);
      print('🌐 Abrindo PDF no navegador: $uri');

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Abre em nova janela do navegador
        );
        print('✅ PDF aberto no navegador');
      } else {
        print('❌ Não foi possível abrir URL: $uri');
      }
    } catch (e) {
      print('❌ Erro ao abrir PDF no navegador: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: AppColors.gray50,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_pdfPath == null) {
      return Container(
        color: AppColors.gray50,
        child: const Center(
          child: Text('Erro ao carregar PDF'),
        ),
      );
    }

    return Container(
      color: AppColors.gray50,
      child: Column(
        children: [
          // Botão para abrir no navegador
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            child: Column(
              children: [
                const Text(
                  'Para melhor experiência com zoom',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openInBrowser,
                    icon: const Icon(Icons.open_in_browser, size: 20),
                    label: const Text('Abrir PDF no Navegador'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Preview do PDF (sem zoom funcional)
          Expanded(
            child: SfPdfViewer.file(
              File(_pdfPath!),
              enableTextSelection: true,
              canShowScrollHead: true,
              canShowScrollStatus: true,
            ),
          ),
        ],
      ),
    );
  }
}

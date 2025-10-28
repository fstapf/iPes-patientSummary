import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../constants/app_colors.dart';

/// Visualizador de PDF para Web usando iframe
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
  late String _iframeId;

  @override
  void initState() {
    super.initState();
    _iframeId = 'pdf-viewer-${DateTime.now().millisecondsSinceEpoch}';
    _registerIframe();
  }

  void _registerIframe() {
    print('🌐 Registrando iframe para PDF na web');

    // Criar blob do PDF
    final blob = html.Blob([widget.pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    print('📄 Blob URL criada: $url');

    // Criar iframe
    final iframe = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';

    // Registrar view
    ui_web.platformViewRegistry.registerViewFactory(
      _iframeId,
      (int viewId) => iframe,
    );

    print('✅ Iframe registrado com ID: $_iframeId');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gray50,
      child: HtmlElementView(
        viewType: _iframeId,
      ),
    );
  }
}

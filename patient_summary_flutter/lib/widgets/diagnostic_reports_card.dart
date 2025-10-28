import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient_data.dart';
import '../constants/app_colors.dart';
import '../services/api_service.dart';
import 'pdf_viewer_dialog.dart';

/// Widget para exibir lista de exames diagnósticos
class DiagnosticReportsCard extends StatelessWidget {
  final List<DiagnosticReportData> reports;
  final String cpf;

  const DiagnosticReportsCard({
    super.key,
    required this.reports,
    required this.cpf,
  });

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Exames Realizados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum exame encontrado',
                style: TextStyle(
                  color: AppColors.gray600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Exames Realizados (${reports.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reports.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final report = reports[index];
                return _buildReportItem(context, report);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, DiagnosticReportData report) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.code,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    if (report.category != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(report.category!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          report.category!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (report.status != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report.status!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report.status!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (report.issued != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.gray600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Realizado em: ${_formatDate(report.issued!)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.gray700,
                  ),
                ),
              ],
            ),
          ],
          if (report.performerName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 14,
                  color: AppColors.gray600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Responsável: ${report.performerName}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (report.pdfUrl != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openPdf(context, report),
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('Ver Resultado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'RADIOLOGY':
        return Colors.blue;
      case 'CAT SCAN':
        return Colors.purple;
      case 'RADIOLOGY ULTRASOUND':
        return Colors.teal;
      case 'CYTOPATHOLOGY':
        return Colors.orange;
      case 'OTHER':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'final':
        return Colors.green;
      case 'preliminary':
        return Colors.orange;
      case 'amended':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.gray600;
    }
  }

  Future<void> _openPdf(BuildContext context, DiagnosticReportData report) async {
    print('🎯 _openPdf chamado para: ${report.code}');
    print('🎯 PDF URL: ${report.pdfUrl}');

    if (report.pdfUrl == null) {
      print('❌ PDF URL é null!');
      return;
    }

    // Mostrar loading
    print('⏳ Mostrando loading dialog...');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Carregando PDF...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Extrair o ID do Binary da URL
      // URL exemplo: Binary/1.3.6.1.4.1.54413.1.1.4.1.1761014569433490008
      final binaryId = report.pdfUrl!.split('/').last;

      final apiService = ApiService();
      final pdfBytesList = await apiService.fetchPdfBytes(binaryId, cpf);
      final pdfBytes = Uint8List.fromList(pdfBytesList);

      print('✅ PDF carregado - ${pdfBytes.length} bytes');
      print('🔍 Primeiros bytes: ${pdfBytes.take(10).toList()}');

      // Fechar loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Abrir PDF em um modal com visualizador
      if (context.mounted) {
        print('📱 Abrindo dialog do PDF viewer');
        showDialog(
          context: context,
          builder: (context) => PdfViewerDialog(
            pdfBytes: pdfBytes,
            title: report.code,
          ),
        );
      }

    } catch (e) {
      // Fechar loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Mostrar erro
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

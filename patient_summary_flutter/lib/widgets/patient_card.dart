import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/patient_data.dart';

/// Card expandível do paciente baseado no design original
class PatientCard extends StatefulWidget {
  final PatientData patient;
  final int index;

  const PatientCard({
    super.key,
    required this.patient,
    required this.index,
  });

  @override
  State<PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<PatientCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      // Extrair timezone da string original (ex: -03:00, +00:00)
      final tzRegex = RegExp(r'([+-]\d{2}):?(\d{2})$');
      final tzMatch = tzRegex.firstMatch(dateString);

      String tzString = 'TZ+00:00';
      if (tzMatch != null) {
        final tzHours = tzMatch.group(1);
        final tzMinutes = tzMatch.group(2);
        tzString = 'TZ$tzHours:$tzMinutes';
      }

      // Parse e formata a data
      final date = DateTime.parse(dateString);
      return '${DateFormat('dd/MM/yyyy HH:mm:ss', 'pt_BR').format(date)} $tzString';
    } catch (e) {
      // Em caso de erro, retorna a string original
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.patient.id.substring(0, 2).toUpperCase();
    final encounterDate = _formatDate(widget.patient.encounter.periodStart);
    final encounterType = widget.patient.encounter.classDisplay ?? 'N/A';
    final status = widget.patient.encounter.status == 'finished'
        ? 'Finalizado'
        : 'Em andamento';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - sempre visível
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(12),
              bottom: _isExpanded ? Radius.zero : const Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF8F9FA), AppColors.white],
                ),
                border: _isExpanded
                    ? const Border(
                        bottom: BorderSide(color: AppColors.gray100))
                    : null,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, Color(0xFF0056B3)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          encounterType,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 24,
                          runSpacing: 8,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: AppColors.gray600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  encounterDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.gray600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: status == 'Finalizado'
                                    ? AppColors.statusCompletedBg
                                    : AppColors.statusProgressBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: status == 'Finalizado'
                                      ? AppColors.success
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Expand icon
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.gray500,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content - scrollável com altura máxima
          if (_isExpanded)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 600, // Altura máxima do conteúdo expandido
                ),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEncounterInfo(),
                        const SizedBox(height: 32),
                        _buildConditions(),
                        const SizedBox(height: 32),
                        _buildAllergies(),
                        const SizedBox(height: 32),
                        _buildProcedures(),
                        const SizedBox(height: 32),
                        _buildMedications(),
                        if (widget.patient.clinicalImpression != null) ...[
                          const SizedBox(height: 32),
                          _buildClinicalImpression(),
                        ],
                        if (widget.patient.carePlan != null) ...[
                          const SizedBox(height: 32),
                          _buildCarePlan(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 20, color: AppColors.gray700),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
      ],
    );
  }

  Widget _buildEncounterInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informações do Atendimento', Icons.info),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                  'ID do Encontro', widget.patient.encounter.id ?? 'N/A'),
              const SizedBox(height: 12),
              _buildInfoRow(
                  'Status', widget.patient.encounter.status ?? 'N/A'),
              const SizedBox(height: 12),
              _buildInfoRow('Modalidade',
                  widget.patient.encounter.classDisplay ?? 'N/A'),
              const SizedBox(height: 12),
              _buildInfoRow('Data de Início',
                  _formatDate(widget.patient.encounter.periodStart)),
              if (widget.patient.encounter.periodEnd != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Data da Alta',
                    _formatDate(widget.patient.encounter.periodEnd)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Diagnósticos', Icons.medical_services),
        const SizedBox(height: 16),
        if (widget.patient.conditions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Nenhum diagnóstico registrado',
                style: TextStyle(
                  color: AppColors.gray500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Table(
              border: TableBorder.symmetric(
                inside: const BorderSide(color: AppColors.gray100),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(3),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  children: [
                    _buildTableHeader('Código'),
                    _buildTableHeader('Descrição'),
                  ],
                ),
                ...widget.patient.conditions.map((condition) {
                  return TableRow(
                    children: [
                      _buildTableCell(condition.code),
                      _buildTableCell(condition.display),
                    ],
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAllergies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Alergias e Intolerâncias', Icons.warning),
        const SizedBox(height: 16),
        if (widget.patient.allergies.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Nenhuma alergia registrada',
                style: TextStyle(
                  color: AppColors.gray500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ...widget.patient.allergies.map((allergy) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: allergy.criticality == 'high'
                        ? AppColors.error
                        : allergy.criticality == 'low'
                            ? AppColors.primary
                            : AppColors.warning,
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          allergy.text,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: allergy.criticality == 'high'
                              ? AppColors.alertHighBg
                              : allergy.criticality == 'low'
                                  ? AppColors.alertLowBg
                                  : AppColors.alertMediumBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning,
                              size: 14,
                              color: allergy.criticality == 'high'
                                  ? AppColors.error
                                  : allergy.criticality == 'low'
                                      ? AppColors.primary
                                      : const Color(0xFF856404),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              allergy.criticality == 'high'
                                  ? 'Alta'
                                  : allergy.criticality == 'low'
                                      ? 'Baixa'
                                      : 'Média',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: allergy.criticality == 'high'
                                    ? AppColors.error
                                    : allergy.criticality == 'low'
                                        ? AppColors.primary
                                        : const Color(0xFF856404),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Categoria: ${allergy.category ?? "N/A"}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildProcedures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Procedimentos Realizados', Icons.healing),
        const SizedBox(height: 16),
        if (widget.patient.procedures.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Nenhum procedimento registrado',
                style: TextStyle(
                  color: AppColors.gray500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Table(
              border: TableBorder.symmetric(
                inside: const BorderSide(color: AppColors.gray100),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  children: [
                    _buildTableHeader('Código'),
                    _buildTableHeader('Descrição'),
                    _buildTableHeader('Data de Realização'),
                  ],
                ),
                ...widget.patient.procedures.map((procedure) {
                  return TableRow(
                    children: [
                      _buildTableCell(procedure.code),
                      _buildTableCell(procedure.display),
                      _buildTableCell(_formatDate(procedure.performedDateTime)),
                    ],
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMedications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Prescrições', Icons.medication),
        const SizedBox(height: 16),
        if (widget.patient.medications.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Nenhuma prescrição registrada',
                style: TextStyle(
                  color: AppColors.gray500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ...widget.patient.medications.map((med) {
            final medications = med.text
                .split(RegExp(r'\d+\)'))
                .where((m) => m.trim().isNotEmpty)
                .toList();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: AppColors.primary, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prescrição de ${_formatDate(med.authoredOn)?.split(' ')[0] ?? "N/A"}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...medications.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key + 1})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.value.trim(),
                              style: const TextStyle(
                                color: AppColors.gray700,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildClinicalImpression() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Resumo da Evolução Clínica', Icons.notes),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.patient.clinicalImpression?.summary ?? 'N/A',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray700,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarePlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Plano de Cuidados', Icons.assignment),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.patient.carePlan?.description ?? 'N/A',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray700,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.gray700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.gray800,
        ),
      ),
    );
  }
}
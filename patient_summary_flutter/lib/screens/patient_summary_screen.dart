import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../models/patient_data.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/patient_card.dart';
import 'login_screen.dart';

/// Tela principal de visualização de pacientes baseada no design original
class PatientSummaryScreen extends StatefulWidget {
  const PatientSummaryScreen({super.key});

  @override
  State<PatientSummaryScreen> createState() => _PatientSummaryScreenState();
}

class _PatientSummaryScreenState extends State<PatientSummaryScreen> {
  final _cpfController = TextEditingController();
  final _apiService = ApiService();
  final _authService = AuthService();

  final List<PatientData> _patients = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _showSearchArea = true;

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  Future<void> _searchPatient() async {
    final cpf = _cpfController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final patientData = await _apiService.searchPatientByCpf(cpf);

      setState(() {
        _patients.add(patientData);
        _isLoading = false;
        _showSearchArea = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _clearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Dados'),
        content: const Text(
            'Tem certeza que deseja limpar todos os dados carregados?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _patients.clear();
                _showSearchArea = true;
                _cpfController.clear();
                _errorMessage = null;
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair do sistema?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Visualizador de Atendimentos FHIR',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        actions: [
          if (_patients.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: _clearData,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar Dados'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gray100,
                  foregroundColor: AppColors.gray700,
                  elevation: 0,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gray700,
                side: const BorderSide(color: AppColors.gray300),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          margin: const EdgeInsets.symmetric(horizontal: 68),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: _showSearchArea ? _buildSearchArea() : _buildPatientsView(),
        ),
      ),
    );
  }

  Widget _buildSearchArea() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.gray200, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Buscar Sumário de Paciente',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Digite o CPF do paciente para buscar o sumário',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cpfController,
                    decoration: InputDecoration(
                      hintText: 'Digite o CPF (apenas números)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.gray300,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.gray300,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      letterSpacing: 1,
                      fontSize: 16,
                    ),
                    onSubmitted: (_) => _searchPatient(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(width: 8),
                      Text(
                        'Buscar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _isLoading
                              ? AppColors.gray500
                              : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.gray600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Buscando dados do paciente...',
                      style: TextStyle(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.alertHighBg,
                  borderRadius: BorderRadius.circular(6),
                  border: const Border(
                    left: BorderSide(color: AppColors.error, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats cards
        _buildStatsCards(),
        const SizedBox(height: 32),

        // Patients list
        Expanded(
          child: ListView.builder(
            itemCount: _patients.length,
            itemBuilder: (context, index) {
              return PatientCard(
                patient: _patients[index],
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final totalConditions =
        _patients.fold<int>(0, (sum, p) => sum + p.conditions.length);
    final totalAllergies =
        _patients.fold<int>(0, (sum, p) => sum + p.allergies.length);
    final totalProcedures =
        _patients.fold<int>(0, (sum, p) => sum + p.procedures.length);

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 2,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Total de Atendimentos', _patients.length.toString()),
        _buildStatCard('Diagnósticos', totalConditions.toString()),
        _buildStatCard('Alergias Registradas', totalAllergies.toString()),
        _buildStatCard('Procedimentos', totalProcedures.toString()),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }
}
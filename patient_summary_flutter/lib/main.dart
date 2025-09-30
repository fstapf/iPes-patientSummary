import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/patient_summary_screen.dart';
import 'services/auth_service.dart';

// Import condicional: usa window_config_stub.dart na web, window_config.dart no desktop
import 'utils/window_config_stub.dart'
    if (dart.library.io) 'utils/window_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  // Configurar janela (só funciona no desktop)
  await configureWindow();

  runApp(const MyApp());
}

/// Aplicação principal - Visualizador de Atendimentos FHIR
/// Convertido de HTML/CSS/JavaScript para Flutter mantendo o design original
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPDATA SGH - PatientSummary - iPes',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthCheck(),
    );
  }
}

/// Widget que verifica autenticação ao iniciar
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return FutureBuilder<bool>(
      future: authService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return const PatientSummaryScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

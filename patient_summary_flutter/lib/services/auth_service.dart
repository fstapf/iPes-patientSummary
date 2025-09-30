import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de autenticação para login e logout
class AuthService {
  static const String _keyLoggedIn = 'userLoggedIn';
  static const String _keyCurrentUser = 'currentUser';

  // Credenciais mockadas (como no original)
  static const String validUsername = 'SPDATA';
  static const String validPassword = 'Spdata@260788#';

  /// Verifica se o usuário está autenticado
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  /// Realiza o login
  Future<bool> login(String username, String password) async {
    // Simular delay de autenticação
    await Future.delayed(const Duration(seconds: 1));

    // Validação mockada
    if (username == validUsername && password == validPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLoggedIn, true);
      await prefs.setString(_keyCurrentUser, username);
      return true;
    }

    return false;
  }

  /// Realiza o logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyCurrentUser);
  }

  /// Obtém o usuário atual
  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentUser);
  }
}
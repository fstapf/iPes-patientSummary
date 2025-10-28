import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/patient_data.dart';

/// Serviço de API FHIR para buscar dados de pacientes
class ApiService {
  // Para usar com proxy local (desenvolvimento):
  // static const String baseUrl = 'http://localhost:3000';

  // Para usar direto (Windows desktop):
  // static const String baseUrl = 'https://dev.ipes.tech:9444';

  // Para usar com proxy hospedado (produção):
  //static const String baseUrl = 'https://ipes-proxy-server.onrender.com';
  static const String baseUrl = 'http://localhost:3000';

  static const String clientId = 'SQybqHk8DOEpbXoT_Jf4e9HVpj8a';
  static const String clientSecret = 'QXwmNti9h6jLu8rTuLyUKuzhbVEa';

  String? _accessToken;
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // Adicionar interceptor para debug
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
        print('📋 Headers: ${options.headers}');
        print('📤 Data: ${options.data}');
        print('📤 Data type: ${options.data.runtimeType}');
        if (options.data is String) {
          print('📤 Data bytes: ${utf8.encode(options.data as String)}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ RESPONSE[${response.statusCode}]');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ ERROR[${error.response?.statusCode}]');
        return handler.next(error);
      },
    ));
  }

  /// Obtém o token de acesso da API
  Future<String> getAccessToken() async {
    try {
      print('🔑 Buscando token de acesso com Dio...');

      final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

      print('🔐 Credentials: Basic $credentials');

      // Enviar como string raw no formato x-www-form-urlencoded
      // Exatamente como o curl faz
      final formData = 'grant_type=client_credentials';

      print('📤 Enviando: $formData');

      final response = await _dio.post(
        '/token',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Basic $credentials',
            'Accept': '*/*',  // Igual ao curl!
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'Dart/Flutter',
          },
          validateStatus: (status) => status! < 500, // Não lançar exceção em 4xx
        ),
      );

      print('📡 Response data: ${response.data}');
      print('📡 Status da autenticação: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('❌ Falha na autenticação');
        throw Exception('Erro na autenticação: ${response.statusCode} - ${response.data}');
      }

      print('✅ Token obtido com sucesso');

      _accessToken = response.data['access_token'] as String;
      return _accessToken!;
    } on DioException catch (e) {
      print('❌ Erro Dio: ${e.message}');
      if (e.response != null) {
        print('📡 Status: ${e.response?.statusCode}');
        print('❌ Corpo da resposta: ${e.response?.data}');
      }
      throw Exception('Falha na autenticação: ${e.message}');
    } catch (error) {
      print('❌ Erro ao obter token: $error');
      throw Exception('Falha na autenticação: $error');
    }
  }

  /// Busca o sumário do paciente pelo CPF
  Future<PatientData> searchPatientByCpf(String cpf) async {
    try {
      // Validar CPF
      if (cpf.isEmpty) {
        throw Exception('Por favor, digite um CPF');
      }

      if (cpf.length != 11) {
        throw Exception('CPF deve ter exatamente 11 dígitos');
      }

      if (!RegExp(r'^\d{11}$').hasMatch(cpf)) {
        throw Exception('CPF deve conter apenas números');
      }

      // Obter token se não tiver ou se expirou
      if (_accessToken == null) {
        await getAccessToken();
      }

      final path = '/ehrrunner/fhir/1.0.1/Patient/2.16.840.1.113883.13.237-$cpf/\$patientsummary';

      print('🔍 Buscando paciente CPF: $cpf');
      print('🌐 Path: $path');
      print('👤 subject-id: $cpf (próprio paciente)');

      try {
        final response = await _dio.get(
          path,
          options: Options(
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Accept': 'application/fhir+json',
              'subject-id': cpf,  // Usar o CPF do paciente que está sendo consultado
            },
          ),
        );

        print('📡 Status da busca: ${response.statusCode}');
        print('✅ Dados do paciente recebidos com sucesso');
        print('📦 Bundle recebido: ${response.data.runtimeType}');
        print('📦 Bundle entries: ${response.data['entry']?.length ?? 0}');

        final patientData = _processBundle(response.data as Map<String, dynamic>);
        print('👤 Patient data processado: ID=${patientData.id}');
        print('   - Conditions: ${patientData.conditions.length}');
        print('   - Allergies: ${patientData.allergies.length}');
        print('   - Procedures: ${patientData.procedures.length}');
        print('   - Medications: ${patientData.medications.length}');

        return patientData;
      } on DioException catch (e) {
        print('❌ Erro na busca: ${e.message}');

        // Se token expirado (401), tentar renovar
        if (e.response?.statusCode == 401) {
          print('🔄 Token expirado, renovando...');
          await getAccessToken();

          final retryResponse = await _dio.get(
            path,
            options: Options(
              headers: {
                'Authorization': 'Bearer $_accessToken',
                'Accept': 'application/fhir+json',
                'subject-id': cpf,  // Usar o CPF do paciente que está sendo consultado
              },
            ),
          );

          print('📡 Status após renovação: ${retryResponse.statusCode}');
          print('✅ Dados do paciente recebidos com sucesso');

          return _processBundle(retryResponse.data as Map<String, dynamic>);
        }

        if (e.response?.statusCode == 403) {
          final responseData = e.response?.data;
          String errorMsg = 'Acesso negado ao sumário do paciente';

          if (responseData is Map && responseData['issue'] != null) {
            final issues = responseData['issue'] as List;
            if (issues.isNotEmpty && issues[0]['diagnostics'] != null) {
              errorMsg = issues[0]['diagnostics'] as String;
            }
          }

          throw Exception('$errorMsg\n\nPossíveis causas:\n• Paciente não autorizou o acesso aos dados\n• CPF não cadastrado no sistema\n• Permissões insuficientes');
        }

        if (e.response?.statusCode == 404) {
          throw Exception('Paciente não encontrado no sistema');
        }

        if (e.response?.statusCode == 406) {
          throw Exception(
              'Servidor rejeitou a requisição (406). O servidor pode estar exigindo headers específicos ou formato diferente.');
        }

        print('📡 Status: ${e.response?.statusCode}');
        print('❌ Corpo da resposta: ${e.response?.data}');
        throw Exception('Erro na busca: ${e.message}');
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Processa o bundle FHIR e extrai os dados do paciente
  PatientData _processBundle(Map<String, dynamic> bundle) {
    print('🔄 Iniciando processamento do bundle...');

    final patientData = <String, dynamic>{
      'id': '',
      'encounter': <String, dynamic>{},
      'conditions': <Map<String, dynamic>>[],
      'allergies': <Map<String, dynamic>>[],
      'procedures': <Map<String, dynamic>>[],
      'medications': <Map<String, dynamic>>[],
    };

    if (bundle['entry'] == null) {
      throw Exception('Bundle inválido - propriedade entry não encontrada');
    }

    final topLevelEntries = bundle['entry'] as List<dynamic>;
    print('📋 Total de top-level entries: ${topLevelEntries.length}');
    print('📋 Bundle type: ${bundle['type']}');

    // Processar transaction-response: cada entry contém um Bundle do tipo searchset
    for (var i = 0; i < topLevelEntries.length; i++) {
      final topLevelResource = topLevelEntries[i]['resource'] as Map<String, dynamic>?;

      if (topLevelResource == null) continue;

      print('   [$i] Top-level resourceType: ${topLevelResource['resourceType']}');

      // Verificar se é um Bundle aninhado (searchset)
      if (topLevelResource['resourceType'] == 'Bundle' &&
          topLevelResource['type'] == 'searchset') {

        final nestedEntries = topLevelResource['entry'] as List<dynamic>?;
        if (nestedEntries == null) continue;

        print('      └─ Nested bundle com ${nestedEntries.length} entries');

        // Processar recursos dentro do bundle aninhado
        for (final nestedEntry in nestedEntries) {
          final resource = nestedEntry['resource'] as Map<String, dynamic>?;
          if (resource == null) continue;

          final resourceType = resource['resourceType'] as String;
          print('         └─ Resource: $resourceType');

          switch (resourceType) {
            case 'Encounter':
              print('✅ Encounter encontrado!');
              patientData['encounter'] = resource;

              // Extrair ID do atendimento (usar o ID do Encounter como ID principal)
              if (resource['id'] != null) {
                patientData['id'] = resource['id'] as String;
                print('✅ ID do atendimento: ${patientData['id']}');
              }
              break;

            case 'Condition':
              (patientData['conditions'] as List<Map<String, dynamic>>).add(resource);
              break;

            case 'AllergyIntolerance':
              (patientData['allergies'] as List<Map<String, dynamic>>).add(resource);
              break;

            case 'Procedure':
              (patientData['procedures'] as List<Map<String, dynamic>>).add(resource);
              break;

            case 'MedicationRequest':
              (patientData['medications'] as List<Map<String, dynamic>>).add(resource);
              break;

            case 'ClinicalImpression':
              patientData['clinicalImpression'] = resource;
              break;

            case 'CarePlan':
              patientData['carePlan'] = resource;
              break;
          }
        }
      }
    }

    if (patientData['id'] == '') {
      throw Exception('Não foi possível encontrar informações do atendimento no bundle');
    }

    print('📊 Recursos processados:');
    print('   - ID do atendimento: ${patientData['id']}');
    print('   - Conditions: ${(patientData['conditions'] as List).length}');
    print('   - Allergies: ${(patientData['allergies'] as List).length}');
    print('   - Procedures: ${(patientData['procedures'] as List).length}');
    print('   - Medications: ${(patientData['medications'] as List).length}');

    return PatientData.fromJson(patientData);
  }

  /// Busca exames diagnósticos do paciente pelo CPF
  Future<List<DiagnosticReportData>> searchDiagnosticReportsByCpf(String cpf) async {
    try {
      // Validar CPF
      if (cpf.isEmpty) {
        throw Exception('Por favor, digite um CPF');
      }

      if (cpf.length != 11) {
        throw Exception('CPF deve ter exatamente 11 dígitos');
      }

      if (!RegExp(r'^\d{11}$').hasMatch(cpf)) {
        throw Exception('CPF deve conter apenas números');
      }

      // Obter token se não tiver ou se expirou
      if (_accessToken == null) {
        await getAccessToken();
      }

      final path = '/ehrrunner/fhir/1.0.1/DiagnosticReport?patient=Patient/2.16.840.1.113883.13.237-$cpf&_sort=-issued&_include=DiagnosticReport:based-on&status=final';

      print('🔍 Buscando exames para CPF: $cpf');
      print('🌐 Path: $path');
      print('👤 subject-id: $cpf (próprio paciente)');

      try {
        final response = await _dio.get(
          path,
          options: Options(
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Accept': 'application/fhir+json',
              'subject-id': cpf,  // Usar o CPF do paciente que está sendo consultado
            },
          ),
        );

        print('📡 Status da busca de exames: ${response.statusCode}');
        print('✅ Exames recebidos com sucesso');

        return _processDiagnosticReportsBundle(response.data as Map<String, dynamic>);
      } on DioException catch (e) {
        print('❌ Erro na busca de exames: ${e.message}');

        // Se token expirado (401), tentar renovar
        if (e.response?.statusCode == 401) {
          print('🔄 Token expirado, renovando...');
          await getAccessToken();

          final retryResponse = await _dio.get(
            path,
            options: Options(
              headers: {
                'Authorization': 'Bearer $_accessToken',
                'Accept': 'application/fhir+json',
                'subject-id': cpf,  // Usar o CPF do paciente que está sendo consultado
              },
            ),
          );

          print('📡 Status após renovação: ${retryResponse.statusCode}');
          print('✅ Exames recebidos com sucesso');

          return _processDiagnosticReportsBundle(retryResponse.data as Map<String, dynamic>);
        }

        if (e.response?.statusCode == 404) {
          // Nenhum exame encontrado - retornar lista vazia ao invés de erro
          print('ℹ️ Nenhum exame encontrado para este paciente');
          return [];
        }

        print('📡 Status: ${e.response?.statusCode}');
        print('❌ Corpo da resposta: ${e.response?.data}');
        throw Exception('Erro ao buscar exames: ${e.message}');
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Processa o bundle de DiagnosticReports
  List<DiagnosticReportData> _processDiagnosticReportsBundle(Map<String, dynamic> bundle) {
    print('🔄 Processando bundle de exames...');

    final diagnosticReports = <DiagnosticReportData>[];

    if (bundle['entry'] == null) {
      print('ℹ️ Bundle sem entries - nenhum exame encontrado');
      return diagnosticReports;
    }

    final entries = bundle['entry'] as List<dynamic>;
    print('📋 Total de entries: ${entries.length}');

    for (var entry in entries) {
      final resource = entry['resource'] as Map<String, dynamic>?;
      if (resource == null) continue;

      // Apenas processar DiagnosticReport (ignorar ServiceRequest incluídos)
      if (resource['resourceType'] == 'DiagnosticReport') {
        try {
          diagnosticReports.add(DiagnosticReportData.fromJson(resource));
        } catch (e) {
          print('⚠️ Erro ao processar DiagnosticReport: $e');
        }
      }
    }

    print('📊 Total de exames processados: ${diagnosticReports.length}');
    return diagnosticReports;
  }

  /// Busca o PDF de um exame diagnóstico
  Future<List<int>> fetchPdfBytes(String binaryId, String cpf) async {
    try {
      // Obter token se não tiver ou se expirou
      if (_accessToken == null) {
        await getAccessToken();
      }

      final path = '/ehrrunner/fhir/1.0.1/Binary/$binaryId';

      print('📄 Buscando PDF: $binaryId');
      print('🌐 Path: $path');

      try {
        final response = await _dio.get(
          path,
          options: Options(
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Accept': 'application/fhir+json',  // Header necessário para obter o JSON com base64
              'subject-id': cpf,
            },
          ),
        );

        print('📡 Status da busca de PDF: ${response.statusCode}');

        final data = response.data as Map<String, dynamic>;

        // Validar resposta
        if (data['resourceType'] != 'Binary') {
          throw Exception('Resposta inválida - esperado resourceType Binary');
        }

        if (data['contentType'] != 'application/pdf') {
          throw Exception('Tipo de conteúdo inválido - esperado application/pdf');
        }

        final base64Data = data['data'] as String?;
        if (base64Data == null) {
          throw Exception('PDF não contém dados');
        }

        print('✅ PDF recebido - decodificando base64...');

        // Decodificar base64 para bytes
        final pdfBytes = base64Decode(base64Data);
        print('✅ PDF decodificado - ${pdfBytes.length} bytes');

        return pdfBytes;

      } on DioException catch (e) {
        print('❌ Erro ao buscar PDF: ${e.message}');

        // Se token expirado (401), tentar renovar
        if (e.response?.statusCode == 401) {
          print('🔄 Token expirado, renovando...');
          await getAccessToken();

          final retryResponse = await _dio.get(
            path,
            options: Options(
              headers: {
                'Authorization': 'Bearer $_accessToken',
                'Accept': 'application/fhir+json',
                'subject-id': cpf,
              },
            ),
          );

          print('📡 Status após renovação: ${retryResponse.statusCode}');

          final data = retryResponse.data as Map<String, dynamic>;
          final base64Data = data['data'] as String;
          return base64Decode(base64Data);
        }

        print('📡 Status: ${e.response?.statusCode}');
        print('❌ Corpo da resposta: ${e.response?.data}');
        throw Exception('Erro ao buscar PDF: ${e.message}');
      }
    } catch (error) {
      print('❌ Erro ao processar PDF: $error');
      rethrow;
    }
  }
}
/// Modelo de dados do paciente baseado no bundle FHIR
class PatientData {
  final String id;
  final EncounterData encounter;
  final List<ConditionData> conditions;
  final List<AllergyData> allergies;
  final List<ProcedureData> procedures;
  final List<MedicationData> medications;
  final ClinicalImpressionData? clinicalImpression;
  final CarePlanData? carePlan;

  PatientData({
    required this.id,
    required this.encounter,
    required this.conditions,
    required this.allergies,
    required this.procedures,
    required this.medications,
    this.clinicalImpression,
    this.carePlan,
  });

  factory PatientData.fromJson(Map<String, dynamic> json) {
    return PatientData(
      id: json['id'] as String,
      encounter: EncounterData.fromJson(json['encounter'] as Map<String, dynamic>),
      conditions: (json['conditions'] as List<dynamic>)
          .map((e) => ConditionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      allergies: (json['allergies'] as List<dynamic>)
          .map((e) => AllergyData.fromJson(e as Map<String, dynamic>))
          .toList(),
      procedures: (json['procedures'] as List<dynamic>)
          .map((e) => ProcedureData.fromJson(e as Map<String, dynamic>))
          .toList(),
      medications: (json['medications'] as List<dynamic>)
          .map((e) => MedicationData.fromJson(e as Map<String, dynamic>))
          .toList(),
      clinicalImpression: json['clinicalImpression'] != null
          ? ClinicalImpressionData.fromJson(json['clinicalImpression'] as Map<String, dynamic>)
          : null,
      carePlan: json['carePlan'] != null
          ? CarePlanData.fromJson(json['carePlan'] as Map<String, dynamic>)
          : null,
    );
  }
}

class EncounterData {
  final String? id;
  final String? status;
  final String? classDisplay;
  final String? classCode;
  final String? periodStart;
  final String? periodEnd;
  final String? dischargeDisposition;
  final String? eventSummaryType;
  final double? weight;
  final double? height;

  EncounterData({
    this.id,
    this.status,
    this.classDisplay,
    this.classCode,
    this.periodStart,
    this.periodEnd,
    this.dischargeDisposition,
    this.eventSummaryType,
    this.weight,
    this.height,
  });

  factory EncounterData.fromJson(Map<String, dynamic> json) {
    // Extrair apenas o número do atendimento do OID (penúltimo segmento)
    String? extractEncounterId(String? fullId) {
      if (fullId == null) return null;
      final segments = fullId.split('.');
      if (segments.length >= 2) {
        return segments[segments.length - 2]; // Penúltimo segmento
      }
      return fullId;
    }

    // Extrair EventSummaryType das tags
    String? eventSummaryType;
    if (json['meta'] != null && json['meta']['tag'] != null) {
      final tags = json['meta']['tag'] as List<dynamic>;
      for (var tag in tags) {
        if (tag['system'] != null &&
            (tag['system'].toString().contains('EventSummaryType') ||
             tag['system'].toString().contains('CodingSystem/EventSummaryType'))) {
          eventSummaryType = tag['code'] as String?;
          break;
        }
      }
    }

    // Extrair peso e altura se disponíveis
    double? weight;
    double? height;
    if (json['weight'] != null) {
      weight = (json['weight'] is int) ? (json['weight'] as int).toDouble() : json['weight'] as double?;
    }
    if (json['height'] != null) {
      height = (json['height'] is int) ? (json['height'] as int).toDouble() : json['height'] as double?;
    }

    return EncounterData(
      id: extractEncounterId(json['id'] as String?),
      status: json['status'] as String?,
      classDisplay: json['class']?['display'] as String?,
      classCode: json['class']?['code'] as String?,
      periodStart: json['period']?['start'] as String?,
      periodEnd: json['period']?['end'] as String?,
      dischargeDisposition: json['hospitalization']?['dischargeDisposition']?['coding']?[0]?['display'] as String?,
      eventSummaryType: eventSummaryType,
      weight: weight,
      height: height,
    );
  }
}

class ConditionData {
  final String? id;
  final String code;
  final String display;
  final String? recordedDate;
  final String? clinicalStatus;

  ConditionData({
    this.id,
    required this.code,
    required this.display,
    this.recordedDate,
    this.clinicalStatus,
  });

  factory ConditionData.fromJson(Map<String, dynamic> json) {
    return ConditionData(
      id: json['id'] as String?,
      code: json['code']['coding'][0]['code'] as String,
      display: json['code']['coding'][0]['display'] as String,
      recordedDate: json['recordedDate'] as String?,
      clinicalStatus: json['clinicalStatus']?['coding']?[0]?['code'] as String?,
    );
  }
}

class AllergyData {
  final String? id;
  final String text;
  final String? category;
  final String? criticality;
  final String? clinicalStatus;
  final String? verificationStatus;

  AllergyData({
    this.id,
    required this.text,
    this.category,
    this.criticality,
    this.clinicalStatus,
    this.verificationStatus,
  });

  factory AllergyData.fromJson(Map<String, dynamic> json) {
    return AllergyData(
      id: json['id'] as String?,
      text: json['code']['text'] as String,
      category: json['category'] != null && (json['category'] as List).isNotEmpty
          ? json['category'][0] as String
          : null,
      criticality: json['criticality'] as String?,
      clinicalStatus: json['clinicalStatus']?['coding']?[0]?['code'] as String?,
      verificationStatus: json['verificationStatus']?['coding']?[0]?['code'] as String?,
    );
  }
}

class ProcedureData {
  final String? id;
  final String code;
  final String display;
  final String? performedDateTime;

  ProcedureData({
    this.id,
    required this.code,
    required this.display,
    this.performedDateTime,
  });

  factory ProcedureData.fromJson(Map<String, dynamic> json) {
    return ProcedureData(
      id: json['id'] as String?,
      code: json['code']['coding'][0]['code'] as String,
      display: json['code']['coding'][0]['display'] as String,
      performedDateTime: json['performedDateTime'] as String?,
    );
  }
}

class MedicationData {
  final String? id;
  final String text;
  final String? authoredOn;

  MedicationData({
    this.id,
    required this.text,
    this.authoredOn,
  });

  factory MedicationData.fromJson(Map<String, dynamic> json) {
    return MedicationData(
      id: json['id'] as String?,
      text: json['medicationCodeableConcept']['text'] as String,
      authoredOn: json['authoredOn'] as String?,
    );
  }
}

class ClinicalImpressionData {
  final String? id;
  final String? summary;

  ClinicalImpressionData({
    this.id,
    this.summary,
  });

  factory ClinicalImpressionData.fromJson(Map<String, dynamic> json) {
    return ClinicalImpressionData(
      id: json['id'] as String?,
      summary: json['summary'] as String?,
    );
  }
}

class CarePlanData {
  final String? id;
  final String? description;
  final String? status;

  CarePlanData({
    this.id,
    this.description,
    this.status,
  });

  factory CarePlanData.fromJson(Map<String, dynamic> json) {
    return CarePlanData(
      id: json['id'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
    );
  }
}

class DiagnosticReportData {
  final String? id;
  final String? status;
  final String? category;
  final String code;
  final String? issued;
  final String? pdfUrl;
  final String? performerName;

  DiagnosticReportData({
    this.id,
    this.status,
    this.category,
    required this.code,
    this.issued,
    this.pdfUrl,
    this.performerName,
  });

  factory DiagnosticReportData.fromJson(Map<String, dynamic> json) {
    String? categoryDisplay;
    if (json['category'] != null && (json['category'] as List).isNotEmpty) {
      final categoryList = json['category'] as List;
      if (categoryList[0]['coding'] != null && (categoryList[0]['coding'] as List).isNotEmpty) {
        categoryDisplay = categoryList[0]['coding'][0]['display'] as String?;
      }
    }

    String? pdfUrl;
    if (json['presentedForm'] != null && (json['presentedForm'] as List).isNotEmpty) {
      pdfUrl = json['presentedForm'][0]['url'] as String?;
    }

    String? performerName;
    if (json['contained'] != null && (json['contained'] as List).isNotEmpty) {
      final practitioner = (json['contained'] as List).firstWhere(
        (item) => item['resourceType'] == 'Practitioner',
        orElse: () => null,
      );
      if (practitioner != null && practitioner['name'] != null && (practitioner['name'] as List).isNotEmpty) {
        performerName = practitioner['name'][0]['text'] as String?;
      }
    }

    // Extrair código - proteger contra null
    String code = 'Sem descrição';
    if (json['code'] != null && json['code']['text'] != null) {
      code = json['code']['text'] as String;
    } else if (json['code'] != null && json['code']['coding'] != null && (json['code']['coding'] as List).isNotEmpty) {
      // Tentar pegar do coding se text não estiver disponível
      final coding = (json['code']['coding'] as List)[0];
      code = (coding['display'] ?? coding['code'] ?? 'Sem descrição') as String;
    }

    return DiagnosticReportData(
      id: json['id'] as String?,
      status: json['status'] as String?,
      category: categoryDisplay,
      code: code,
      issued: json['issued'] as String?,
      pdfUrl: pdfUrl,
      performerName: performerName,
    );
  }
}
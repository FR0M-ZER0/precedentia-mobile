class PrecedentModel {
  final int id;
  final String name;
  final String? tribunal;
  final String species;
  final String summary;
  final String description;
  final String situation;
  final String lastUpdate;
  final String url;
  final double score;
  final String applicability;

  const PrecedentModel({
    required this.id,
    required this.name,
    this.tribunal,
    required this.species,
    required this.summary,
    required this.description,
    required this.situation,
    required this.lastUpdate,
    required this.url,
    required this.score,
    required this.applicability,
  });

  factory PrecedentModel.fromJson(Map<String, dynamic> json) {
    return PrecedentModel(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      tribunal: json['tribunal'] as String?,
      species: (json['species'] as String?) ?? '',
      summary: (json['summary'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      situation: (json['situation'] as String?) ?? '',
      lastUpdate: (json['last_update'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      applicability: (json['applicability'] as String?) ?? '',
    );
  }
}

class AnalysisModel {
  final int id;
  final String type;
  final String? tribunal;
  final String facts;
  final String requests;
  final List<PrecedentModel> precedents;
  final DateTime createdAt;

  const AnalysisModel({
    required this.id,
    required this.type,
    required this.facts,
    required this.requests,
    required this.precedents,
    required this.createdAt,
    this.tribunal,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    final precedentsJson = json['precedents'] as List<dynamic>? ?? [];
    return AnalysisModel(
      id: json['id'] as int,
      type: json['type'] as String,
      tribunal: json['tribunal'] as String?,
      facts: json['facts'] as String,
      requests: json['requests'] as String,
      precedents: precedentsJson
          .map((e) => PrecedentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

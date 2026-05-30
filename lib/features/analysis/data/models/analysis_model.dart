class AnalysisModel {
  final int id;
  final String type;
  final String? tribunal;
  final String facts;
  final String requests;
  final DateTime createdAt;

  const AnalysisModel({
    required this.id,
    required this.type,
    required this.facts,
    required this.requests,
    required this.createdAt,
    this.tribunal,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    return AnalysisModel(
      id: json['id'] as int,
      type: json['type'] as String,
      tribunal: json['tribunal'] as String?,
      facts: json['facts'] as String,
      requests: json['requests'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

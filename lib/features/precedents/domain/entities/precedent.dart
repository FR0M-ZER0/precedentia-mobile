enum Compatibility { muitoProvavel, provavel, poucoProvavel }

class Precedent {
  final String id; // Número indicador
  final String court; // Superior Tribunal de Justiça
  final String courtAcronym; // STJ
  final DateTime creationDate; // 01/02/2035
  final String subject; // Herança familiar
  final String summary; // Lorem ipsum... (4 linhas max)
  final double score; // 80.0
  final Compatibility compatibility; // Gerado a partir do score

  Precedent({
    required this.id,
    required this.court,
    required this.courtAcronym,
    required this.creationDate,
    required this.subject,
    required this.summary,
    required this.score,
    required this.compatibility,
  });
}

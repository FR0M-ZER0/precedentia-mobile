enum Compatibility { aplicavel, poucoAplicavel, muitoPoucoAplicavel }

class Precedent {
  final String id;
  final String name;
  final String court;
  final String courtAcronym;
  final DateTime creationDate;
  final String subject;
  final String summary;
  final String description;
  final String type;
  final String situation;
  final double score;
  final Compatibility compatibility;
  final String lastUpdate;
  final String url;

  const Precedent({
    required this.id,
    required this.name,
    required this.court,
    required this.courtAcronym,
    required this.creationDate,
    required this.subject,
    required this.summary,
    required this.description,
    required this.type,
    required this.situation,
    required this.score,
    required this.compatibility,
    required this.lastUpdate,
    required this.url,
  });
}

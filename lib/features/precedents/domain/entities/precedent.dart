enum Compatibility { muitoProvavel, provavel, poucoProvavel, muitoPoucoProvavel }

class Precedent {
  final String id;
  final String name;
  final String court;
  final String courtAcronym;
  final DateTime creationDate;
  final String subject;
  final String summary;
  final String description;
  final String species;
  final String situation;
  final double score;
  final Compatibility compatibility;

  const Precedent({
    required this.id,
    required this.name,
    required this.court,
    required this.courtAcronym,
    required this.creationDate,
    required this.subject,
    required this.summary,
    required this.description,
    required this.species,
    required this.situation,
    required this.score,
    required this.compatibility,
  });
}

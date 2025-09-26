class Issue {
  final String id; // GitHub issue node_id or owner/name#number
  final String title;
  final String body;
  final String repoId; // matches Repository.id
  final List<String> labels;
  final String htmlUrl;
  final bool goodFirstIssue;
  final bool helpWanted;
  final DateTime createdAt;

  const Issue({
    required this.id,
    required this.title,
    required this.body,
    required this.repoId,
    this.labels = const [],
    required this.htmlUrl,
    this.goodFirstIssue = false,
    this.helpWanted = false,
    required this.createdAt,
  });
}

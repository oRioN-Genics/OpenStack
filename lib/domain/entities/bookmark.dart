class Bookmark {
  final String id;
  final String issueId;
  final String repoId;
  final DateTime savedAt;

  const Bookmark({
    required this.id,
    required this.issueId,
    required this.repoId,
    required this.savedAt,
  });
}

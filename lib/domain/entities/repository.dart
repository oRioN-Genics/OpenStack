class Repository {
  final String id; // "owner/name"
  final String name;
  final String owner;
  final int stars;
  final String license;
  final bool archived;
  final DateTime lastCommitAt;
  final String htmlUrl;

  const Repository({
    required this.id,
    required this.name,
    required this.owner,
    required this.stars,
    required this.license,
    required this.archived,
    required this.lastCommitAt,
    required this.htmlUrl,
  });
}

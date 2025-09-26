class ContributionEvent {
  final String id;

  /// PR_OPENED | PR_MERGED | COMMENT
  final String type;
  final String repoId;
  final String? issueId;
  final String prUrl;
  final DateTime at;

  const ContributionEvent({
    required this.id,
    required this.type,
    required this.repoId,
    this.issueId,
    required this.prUrl,
    required this.at,
  });
}

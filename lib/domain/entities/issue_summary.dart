class IssueSummary {
  final String tldr;
  final List<String> firstPrChecklist;

  /// 1 (easiest) .. 5 (hardest)
  final int difficultyScore;

  const IssueSummary({
    required this.tldr,
    this.firstPrChecklist = const [],
    this.difficultyScore = 3,
  });
}

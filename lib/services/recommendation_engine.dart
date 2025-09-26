import 'dart:math';

import 'package:open_stack/core/pagination.dart';
import 'package:open_stack/data/repositories/profile_repository.dart';
import 'package:open_stack/data/sources/github_source.dart';
import 'package:open_stack/domain/entities/issue.dart';
import 'package:open_stack/domain/entities/issue_summary.dart';
import 'package:open_stack/domain/entities/recommendation.dart';
import 'package:open_stack/domain/entities/repository.dart';
import 'package:open_stack/domain/entities/skill_profile.dart';
import 'package:open_stack/services/summary_service.dart';

class RecommendationEngine {
  final GitHubSource github;
  final ProfileRepository profiles;
  final SummaryService summaries;

  RecommendationEngine({
    required this.github,
    required this.profiles,
    required this.summaries,
  });

  Future<List<Recommendation>> recommend(SkillProfile profile) async {
    final issues = await github.searchIssues(
      profile: profile,
      page: const Pagination(),
    );
    final repoIds = issues.map((i) => i.repoId).toSet().toList();
    final reposMap = await github.fetchReposByIds(repoIds);

    final List<Recommendation> out = [];
    for (final issue in issues) {
      final repo = reposMap[issue.repoId];
      if (repo == null) continue;
      if (!passesFilters(repo, profile)) continue;

      final IssueSummary sum = await summaries.summarize(issue);
      final double sc = score(issue, repo, profile);

      out.add(
        Recommendation(issue: issue, repo: repo, score: sc, summary: sum),
      );
    }
    out.sort((a, b) => b.score.compareTo(a.score));
    return out;
  }

  // very simple placeholder scoring
  double score(Issue issue, Repository repo, SkillProfile profile) {
    double s = 0;
    s += min(repo.stars / 1000.0, 2.0); // cap effect
    if (issue.goodFirstIssue) s += 1.5;
    if (issue.helpWanted) s += 1.0;
    // slightly prefer recent issues
    final days = DateTime.now().difference(issue.createdAt).inDays;
    s += (days < 30) ? 1.0 : 0.2;
    return s;
  }

  bool passesFilters(Repository repo, SkillProfile profile) {
    if (repo.archived) return false;
    if (repo.stars < profile.minStars) return false;
    final days = DateTime.now().difference(repo.lastCommitAt).inDays;
    if (days > profile.lastCommitWithinDays) return false;
    return true;
  }
}

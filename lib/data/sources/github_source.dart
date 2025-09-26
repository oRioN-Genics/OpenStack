import 'package:open_stack/core/pagination.dart';
import 'package:open_stack/domain/entities/issue.dart';
import 'package:open_stack/domain/entities/repository.dart';
import 'package:open_stack/domain/entities/contribution_event.dart';
import 'package:open_stack/domain/entities/skill_profile.dart';

abstract class GitHubSource {
  Future<List<Issue>> searchIssues({
    required SkillProfile profile,
    required Pagination page,
  });

  Future<Map<String, Repository>> fetchReposByIds(List<String> ids);

  Future<List<ContributionEvent>> getUserContributions(String ghUsername);

  Future<DateTime> getRepoLastCommit({
    required String owner,
    required String name,
  });

  Future<int> getRepoStars({required String owner, required String name});
}

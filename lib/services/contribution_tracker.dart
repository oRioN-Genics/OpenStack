import 'package:open_stack/data/repositories/contribution_repository.dart';
import 'package:open_stack/data/sources/github_source.dart';

class ContributionTracker {
  final GitHubSource github;
  final ContributionRepository contributions;

  ContributionTracker({required this.github, required this.contributions});

  Future<void> refresh(String ghUsername) async {
    final events = await github.getUserContributions(ghUsername);
    await contributions.upsertAll(events);
  }
}

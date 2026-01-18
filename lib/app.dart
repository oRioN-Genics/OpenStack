import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/data/repositories/profile_repository.dart';
import 'package:open_stack/data/sources/github_rest_source.dart';
import 'package:open_stack/presentation/controllers/onboarding_controller.dart';
import 'package:open_stack/data/sources/github_source.dart';
import 'package:open_stack/domain/entities/skill_profile.dart';
import 'package:open_stack/presentation/controllers/feed_controller.dart';
import 'package:open_stack/presentation/screens/onboarding/onboarding_flow.dart';
import 'package:open_stack/services/ai/heuristic_ai_provider.dart';
import 'package:open_stack/services/recommendation_engine.dart';
import 'package:open_stack/services/summary_service.dart';
import 'package:open_stack/data/repositories/github_auth_repository.dart';
import 'package:open_stack/presentation/controllers/profile_controller.dart';

final githubSourceProvider = Provider<GitHubSource>((ref) {
  final auth = ref.read(authRepositoryProvider);
  return GitHubRestSource(accessToken: auth.getGitHubAccessToken);
});

class OpenStackApp extends StatelessWidget {
  const OpenStackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          GitHubAuthRepository(clientId: 'Ov23liJxIBSUlsLV2SgN'),
        ),
        profileRepositoryProvider.overrideWithValue(_MemoryProfileRepository()),
        recommendationEngineProvider.overrideWith((ref) {
          final github = ref.read(githubSourceProvider);
          final summaries = SummaryService(HeuristicAIProvider());
          return RecommendationEngine(
            github: github,
            profiles: _MemoryProfileRepository(),
            summaries: summaries,
          );
        }),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OpenStack MVP',
        theme: ThemeData(useMaterial3: true),
        home: const OnboardingFlow(),
      ),
    );
  }
}

class _MemoryProfileRepository implements ProfileRepository {
  SkillProfile? _cached;

  @override
  Future<SkillProfile?> load() async => _cached;

  @override
  Future<void> save(SkillProfile p) async {
    _cached = p;
  }
}

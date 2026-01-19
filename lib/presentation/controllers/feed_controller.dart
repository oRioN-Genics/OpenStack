import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/domain/entities/recommendation.dart';
import 'package:open_stack/domain/enums/difficulty_preference.dart';
import 'package:open_stack/services/ai/personalization_service.dart';

class FeedController extends AsyncNotifier<List<Recommendation>> {
  late final PersonalizationService _service;
  _SearchParams? _last;

  @override
  Future<List<Recommendation>> build() async {
    _service = ref.read(personalizationServiceProvider);
    return <Recommendation>[];
  }

  Future<void> load({
    required List<String> domains,
    required List<String> languages,
    required List<String> technologies,
    required String? confidence,
    required String? contributionStyle,
    required DifficultyPreference difficultyPref,
    required int activityDays,
  }) async {
    _last = _SearchParams(
      domains: domains,
      languages: languages,
      technologies: technologies,
      confidence: confidence,
      contributionStyle: contributionStyle,
      difficultyPref: difficultyPref,
      activityDays: activityDays,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _service.searchRecommendations(
        domains: domains,
        languages: languages,
        technologies: technologies,
        confidence: confidence,
        contributionStyle: contributionStyle,
        difficultyPref: difficultyPref.name,
        activityDays: activityDays,
      ),
    );
  }

  Future<void> refresh() async {
    final p = _last;
    if (p == null) return;
    await load(
      domains: p.domains,
      languages: p.languages,
      technologies: p.technologies,
      confidence: p.confidence,
      contributionStyle: p.contributionStyle,
      difficultyPref: p.difficultyPref,
      activityDays: p.activityDays,
    );
  }
}

class _SearchParams {
  _SearchParams({
    required this.domains,
    required this.languages,
    required this.technologies,
    required this.confidence,
    required this.contributionStyle,
    required this.difficultyPref,
    required this.activityDays,
  });

  final List<String> domains;
  final List<String> languages;
  final List<String> technologies;
  final String? confidence;
  final String? contributionStyle;
  final DifficultyPreference difficultyPref;
  final int activityDays;
}

final feedControllerProvider =
    AsyncNotifierProvider<FeedController, List<Recommendation>>(
      FeedController.new,
    );

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/domain/entities/recommendation.dart';
import 'package:open_stack/domain/entities/skill_profile.dart';
import 'package:open_stack/services/recommendation_engine.dart';

class FeedController extends AsyncNotifier<List<Recommendation>> {
  late final RecommendationEngine _engine;
  SkillProfile? _filters;

  @override
  Future<List<Recommendation>> build() async {
    _engine = ref.read(recommendationEngineProvider);
    // nothing to load until user requests; return empty
    return <Recommendation>[];
  }

  Future<void> load(SkillProfile profile) async {
    _filters = profile;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _engine.recommend(profile));
  }

  Future<void> refresh() async {
    final p = _filters;
    if (p == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _engine.recommend(p));
  }

  void applyFilters(SkillProfile p) {
    _filters = p;
  }
}

final feedControllerProvider =
    AsyncNotifierProvider<FeedController, List<Recommendation>>(
      FeedController.new,
    );

final recommendationEngineProvider = Provider<RecommendationEngine>((ref) {
  throw UnimplementedError('RecommendationEngine not provided yet.');
});

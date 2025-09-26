import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/data/repositories/profile_repository.dart';
import 'package:open_stack/domain/entities/skill_profile.dart';
import 'package:open_stack/domain/enums/difficulty_preference.dart';

class OnboardingController extends Notifier<SkillProfile> {
  late final ProfileRepository _profiles;

  @override
  SkillProfile build() {
    _profiles = ref.read(profileRepositoryProvider);
    // initial state
    return const SkillProfile();
  }

  void setLanguages(List<String> l) => state = state.copyWith(languages: l);
  void setDifficulty(DifficultyPreference d) =>
      state = state.copyWith(difficultyPref: d);
  void setMinStars(int n) => state = state.copyWith(minStars: n);
  void setLastCommitWindow(int days) =>
      state = state.copyWith(lastCommitWithinDays: days);

  Future<void> save() async {
    await _profiles.save(state);
  }
}

/// Provider for the controller
final onboardingControllerProvider =
    NotifierProvider<OnboardingController, SkillProfile>(
      OnboardingController.new,
    );

/// Repository provider placeholder (we’ll implement actual repo later)
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError('ProfileRepository not provided yet.');
});

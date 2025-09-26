import 'package:open_stack/domain/enums/difficulty_preference.dart';

class SkillProfile {
  final List<String> languages;
  final DifficultyPreference difficultyPref;
  final int minStars;
  final int lastCommitWithinDays;

  const SkillProfile({
    this.languages = const [],
    this.difficultyPref = DifficultyPreference.any,
    this.minStars = 0,
    this.lastCommitWithinDays = 180,
  });

  SkillProfile copyWith({
    List<String>? languages,
    DifficultyPreference? difficultyPref,
    int? minStars,
    int? lastCommitWithinDays,
  }) {
    return SkillProfile(
      languages: languages ?? this.languages,
      difficultyPref: difficultyPref ?? this.difficultyPref,
      minStars: minStars ?? this.minStars,
      lastCommitWithinDays: lastCommitWithinDays ?? this.lastCommitWithinDays,
    );
  }
}

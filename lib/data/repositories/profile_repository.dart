import 'package:open_stack/domain/entities/skill_profile.dart';

abstract class ProfileRepository {
  Future<SkillProfile?> load();
  Future<void> save(SkillProfile p);
}

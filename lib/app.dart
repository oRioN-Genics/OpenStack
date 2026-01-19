import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/data/repositories/github_auth_repository.dart';
import 'package:open_stack/data/repositories/profile_repository.dart';
import 'package:open_stack/domain/entities/skill_profile.dart';
import 'package:open_stack/presentation/controllers/onboarding_controller.dart';
import 'package:open_stack/presentation/controllers/profile_controller.dart';
import 'package:open_stack/presentation/screens/welcome_page.dart';

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OpenStack MVP',
        theme: ThemeData(useMaterial3: true),
        home: const WelcomePage(),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_stack/data/repositories/github_auth_repository.dart';
import 'package:open_stack/data/repositories/profile_repository.dart';
import 'package:open_stack/domain/entities/skill_profile.dart';
import 'package:open_stack/presentation/controllers/onboarding_controller.dart';
import 'package:open_stack/presentation/controllers/profile_controller.dart';
import 'package:open_stack/presentation/screens/welcome_page.dart';
import 'package:open_stack/data/local/sqlite_bookmark_repository.dart';
import 'package:open_stack/presentation/controllers/issue_detail_controller.dart';

class OpenStackApp extends StatelessWidget {
  const OpenStackApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0A66C2);
    const surface = Color(0xFFF5F7FA);
    const onSurface = Color(0xFF0F172A);
    const muted = Color(0xFF64748B);

    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          GitHubAuthRepository(clientId: 'Ov23liJxIBSUlsLV2SgN'),
        ),
        profileRepositoryProvider.overrideWithValue(_MemoryProfileRepository()),
        bookmarkRepositoryProvider.overrideWithValue(
          SqliteBookmarkRepository(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OpenStack MVP',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: primary,
            onPrimary: Colors.white,
            secondary: Color(0xFF1D9BF0),
            onSecondary: Colors.white,
            error: Color(0xFFB91C1C),
            onError: Colors.white,
            surface: surface,
            onSurface: onSurface,
          ),
          scaffoldBackgroundColor: surface,
          textTheme: GoogleFonts.sourceSans3TextTheme().copyWith(
            titleLarge: GoogleFonts.sourceSans3(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
            titleMedium: GoogleFonts.sourceSans3(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
            bodyMedium: GoogleFonts.sourceSans3(
              fontSize: 15,
              color: onSurface,
            ),
            bodySmall: GoogleFonts.sourceSans3(
              fontSize: 13,
              color: muted,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            foregroundColor: onSurface,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(color: muted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primary, width: 1.5),
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 2,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFFF1F5F9),
            selectedColor: primary.withOpacity(0.15),
            labelStyle: const TextStyle(color: onSurface),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              side: const BorderSide(color: Color(0xFFCBD5F5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primary,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
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

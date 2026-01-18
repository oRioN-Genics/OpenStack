import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_stack/domain/entities/skill_profile.dart';
import 'package:open_stack/domain/enums/difficulty_preference.dart';
import 'package:open_stack/presentation/controllers/feed_controller.dart';
import 'package:open_stack/presentation/controllers/onboarding_controller.dart';
import 'package:open_stack/presentation/screens/onboarding/confidence_style_page.dart';
import 'package:open_stack/presentation/screens/onboarding/domain_selection_page.dart';
import 'package:open_stack/presentation/screens/onboarding/language_selection_page.dart';
import 'package:open_stack/presentation/screens/onboarding/summary_results_page.dart';
import 'package:open_stack/presentation/screens/onboarding/technology_selection_page.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  static const _maxDomains = 5;

  final Set<String> _domains = {};
  final Set<String> _languages = {};
  final Set<String> _technologies = {};
  String? _confidence;
  String? _contributionStyle;

  DifficultyPreference _difficulty = DifficultyPreference.any;
  final TextEditingController _activityDaysController = TextEditingController(
    text: '180',
  );
  final TextEditingController _otherDomainController = TextEditingController();

  int _step = 0;

  static const List<String> _domainOptions = [
    'Web Development',
    'Mobile Apps',
    'AI / ML',
    'DevOps',
    'Cybersecurity',
    'Game Development',
    'Open Hardware',
    'Data Engineering',
  ];

  static const List<String> _defaultLanguages = [
    'Python',
    'JavaScript',
    'TypeScript',
    'Java',
    'Go',
    'C#',
    'C++',
    'Rust',
    'Dart',
    'Ruby',
  ];

  static const Map<String, List<String>> _domainLanguages = {
    'Web Development': ['JavaScript', 'TypeScript', 'Python', 'PHP', 'Ruby'],
    'Mobile Apps': ['Dart', 'Kotlin', 'Swift', 'Java'],
    'AI / ML': ['Python', 'Julia', 'C++'],
    'DevOps': ['Go', 'Python', 'Ruby', 'Bash'],
    'Cybersecurity': ['Python', 'C', 'C++', 'Rust'],
    'Game Development': ['C#', 'C++', 'GDScript', 'Rust'],
    'Open Hardware': ['C', 'C++', 'Rust', 'Python'],
    'Data Engineering': ['Python', 'SQL', 'Scala', 'Java'],
  };

  static const Map<String, List<String>> _techGroups = {
    'Frontend': ['React', 'Flutter', 'Vue', 'Svelte', 'Angular'],
    'Backend': ['Node', 'Django', 'Spring', 'Rails', 'FastAPI'],
    'AI': ['PyTorch', 'TensorFlow', 'scikit-learn'],
    'DevOps': ['Docker', 'Kubernetes', 'Terraform', 'GitHub Actions'],
  };

  static const List<String> _confidenceOptions = [
    'Beginner',
    'Some experience',
    'Comfortable',
  ];

  static const List<String> _contributionOptions = [
    'Documentation',
    'Bug fixes',
    'Small features',
    'Anything',
  ];

  @override
  void dispose() {
    _activityDaysController.dispose();
    _otherDomainController.dispose();
    super.dispose();
  }

  List<String> get _languageSuggestions {
    final set = <String>{};
    for (final domain in _domains) {
      set.addAll(_domainLanguages[domain] ?? const []);
    }
    if (set.isEmpty) {
      set.addAll(_defaultLanguages);
    }
    final list = set.toList()..sort();
    return list;
  }

  void _toggleDomain(String domain) {
    setState(() {
      if (_domains.contains(domain)) {
        _domains.remove(domain);
        return;
      }
      if (_domains.length >= _maxDomains) return;
      _domains.add(domain);
    });
  }

  void _addOtherDomain() {
    final value = _otherDomainController.text.trim();
    if (value.isEmpty) return;
    if (_domains.length >= _maxDomains) return;
    setState(() {
      _domains.add(value);
      _otherDomainController.clear();
    });
  }

  void _toggleLanguage(String language) {
    setState(() {
      if (_languages.contains(language)) {
        _languages.remove(language);
      } else {
        _languages.add(language);
      }
    });
  }

  void _toggleTechnology(String tech) {
    setState(() {
      if (_technologies.contains(tech)) {
        _technologies.remove(tech);
      } else {
        _technologies.add(tech);
      }
    });
  }

  void _setConfidence(String value) {
    setState(() => _confidence = value);
  }

  void _setContributionStyle(String value) {
    setState(() => _contributionStyle = value);
  }

  void _setDifficulty(DifficultyPreference value) {
    setState(() => _difficulty = value);
  }

  void _next() {
    if (_step < 4) {
      setState(() => _step += 1);
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step -= 1);
    }
  }

  void _skipToSummary() {
    setState(() => _step = 4);
  }

  Future<void> _runSearch() async {
    final days = int.tryParse(_activityDaysController.text.trim()) ?? 180;

    final profile = SkillProfile(
      languages: _languages.toList(),
      difficultyPref: _difficulty,
      lastCommitWithinDays: days,
    );

    final onboarding = ref.read(onboardingControllerProvider.notifier);
    onboarding.setLanguages(profile.languages);
    onboarding.setDifficulty(profile.difficultyPref);
    onboarding.setLastCommitWindow(profile.lastCommitWithinDays);
    await onboarding.save();

    await ref.read(feedControllerProvider.notifier).load(profile);
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'What excites you?',
      'What languages are you comfortable with?',
      'What tools or technologies do you know?',
      'Confidence and contribution style',
      'Summary and results',
    ];

    final page = switch (_step) {
      0 => DomainSelectionPage(
        domains: _domains,
        domainOptions: _domainOptions,
        otherDomainController: _otherDomainController,
        maxDomains: _maxDomains,
        onToggleDomain: _toggleDomain,
        onAddOtherDomain: _addOtherDomain,
        onNext: _next,
        onSkip: _skipToSummary,
      ),
      1 => LanguageSelectionPage(
        languageOptions: _languageSuggestions,
        selectedLanguages: _languages,
        onToggleLanguage: _toggleLanguage,
        onBack: _back,
        onNext: _next,
        onSkip: _skipToSummary,
      ),
      2 => TechnologySelectionPage(
        techGroups: _techGroups,
        selectedTechnologies: _technologies,
        onToggleTechnology: _toggleTechnology,
        onBack: _back,
        onNext: _next,
        onSkip: _skipToSummary,
      ),
      3 => ConfidenceStylePage(
        confidenceOptions: _confidenceOptions,
        contributionOptions: _contributionOptions,
        selectedConfidence: _confidence,
        selectedContributionStyle: _contributionStyle,
        onConfidenceChanged: _setConfidence,
        onContributionStyleChanged: _setContributionStyle,
        onBack: _back,
        onNext: _next,
        onSkip: _skipToSummary,
      ),
      _ => SummaryResultsPage(
        domains: _domains.toList(),
        languages: _languages.toList(),
        technologies: _technologies.toList(),
        confidence: _confidence,
        contributionStyle: _contributionStyle,
        difficulty: _difficulty,
        activityDaysController: _activityDaysController,
        onDifficultyChanged: _setDifficulty,
        onSearch: _runSearch,
        onBack: _back,
      ),
    };

    return Scaffold(
      appBar: AppBar(title: Text(titles[_step])),
      body: SafeArea(child: page),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:open_stack/domain/enums/difficulty_preference.dart';

class AdjustmentsData {
  const AdjustmentsData({
    required this.domains,
    required this.languages,
    required this.technologies,
    required this.confidence,
    required this.contributionStyle,
    required this.difficulty,
    required this.activityDays,
  });

  final Set<String> domains;
  final Set<String> languages;
  final Set<String> technologies;
  final String? confidence;
  final String? contributionStyle;
  final DifficultyPreference difficulty;
  final int activityDays;
}

class AdjustmentsSheet extends StatefulWidget {
  const AdjustmentsSheet({
    super.key,
    required this.domainOptions,
    required this.maxDomains,
    required this.initialDomains,
    required this.languageOptions,
    required this.initialLanguages,
    required this.techGroups,
    required this.initialTechnologies,
    required this.confidenceOptions,
    required this.contributionOptions,
    required this.initialConfidence,
    required this.initialContributionStyle,
    required this.initialDifficulty,
    required this.initialActivityDays,
  });

  final List<String> domainOptions;
  final int maxDomains;
  final Set<String> initialDomains;
  final List<String> languageOptions;
  final Set<String> initialLanguages;
  final Map<String, List<String>> techGroups;
  final Set<String> initialTechnologies;
  final List<String> confidenceOptions;
  final List<String> contributionOptions;
  final String? initialConfidence;
  final String? initialContributionStyle;
  final DifficultyPreference initialDifficulty;
  final int initialActivityDays;

  @override
  State<AdjustmentsSheet> createState() => _AdjustmentsSheetState();
}

class _AdjustmentsSheetState extends State<AdjustmentsSheet> {
  late final Set<String> _domains;
  late final Set<String> _languages;
  late final Set<String> _technologies;
  late final TextEditingController _otherDomainController;
  late final TextEditingController _activityDaysController;
  String? _confidence;
  String? _contributionStyle;
  DifficultyPreference _difficulty = DifficultyPreference.any;

  @override
  void initState() {
    super.initState();
    _domains = Set<String>.from(widget.initialDomains);
    _languages = Set<String>.from(widget.initialLanguages);
    _technologies = Set<String>.from(widget.initialTechnologies);
    _confidence = widget.initialConfidence;
    _contributionStyle = widget.initialContributionStyle;
    _difficulty = widget.initialDifficulty;
    _otherDomainController = TextEditingController();
    _activityDaysController = TextEditingController(
      text: widget.initialActivityDays.toString(),
    );
  }

  @override
  void dispose() {
    _otherDomainController.dispose();
    _activityDaysController.dispose();
    super.dispose();
  }

  void _toggle(Set<String> target, String value) {
    setState(() {
      if (target.contains(value)) {
        target.remove(value);
      } else {
        target.add(value);
      }
    });
  }

  void _addOtherDomain() {
    final value = _otherDomainController.text.trim();
    if (value.isEmpty) return;
    if (_domains.length >= widget.maxDomains) return;
    setState(() {
      _domains.add(value);
      _otherDomainController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.92;
    final remaining = widget.maxDomains - _domains.length;

    return SizedBox(
      height: maxHeight,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Adjust your choices', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Update your preferences without leaving this screen.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text('Domains', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.domainOptions.map((domain) {
                      return FilterChip(
                        label: Text(domain),
                        selected: _domains.contains(domain),
                        onSelected: (_) => _toggle(_domains, domain),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _otherDomainController,
                    decoration: const InputDecoration(
                      labelText: 'Other domain',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: remaining > 0 ? _addOtherDomain : null,
                        child: const Text('Add'),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Remaining: $remaining',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Languages', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.languageOptions.map((lang) {
                      return FilterChip(
                        label: Text(lang),
                        selected: _languages.contains(lang),
                        onSelected: (_) => _toggle(_languages, lang),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('Technologies', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...widget.techGroups.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: theme.textTheme.bodySmall),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: entry.value.map((tech) {
                              return FilterChip(
                                label: Text(tech),
                                selected: _technologies.contains(tech),
                                onSelected: (_) => _toggle(_technologies, tech),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Text('Confidence', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  ...widget.confidenceOptions.map((option) {
                    return RadioListTile<String>(
                      value: option,
                      groupValue: _confidence,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _confidence = value);
                      },
                      title: Text(option),
                      dense: true,
                    );
                  }),
                  const SizedBox(height: 12),
                  Text('Contribution style', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  ...widget.contributionOptions.map((option) {
                    return RadioListTile<String>(
                      value: option,
                      groupValue: _contributionStyle,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _contributionStyle = value);
                      },
                      title: Text(option),
                      dense: true,
                    );
                  }),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<DifficultyPreference>(
                    value: _difficulty,
                    items: const [
                      DropdownMenuItem(
                        value: DifficultyPreference.any,
                        child: Text('Any'),
                      ),
                      DropdownMenuItem(
                        value: DifficultyPreference.goodFirst,
                        child: Text('Good first issue'),
                      ),
                      DropdownMenuItem(
                        value: DifficultyPreference.helpWanted,
                        child: Text('Help wanted'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _difficulty = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Difficulty label',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _activityDaysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Activity days',
                      hintText: '180',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    final days =
                        int.tryParse(_activityDaysController.text.trim()) ??
                            widget.initialActivityDays;
                    Navigator.of(context).pop(
                      AdjustmentsData(
                        domains: _domains,
                        languages: _languages,
                        technologies: _technologies,
                        confidence: _confidence,
                        contributionStyle: _contributionStyle,
                        difficulty: _difficulty,
                        activityDays: days,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Apply'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

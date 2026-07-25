import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'floating_card.dart';

/// One numbered section of a legal document — a heading plus one or more
/// paragraphs.
class LegalSection {
  const LegalSection({required this.heading, required this.paragraphs});
  final String heading;
  final List<String> paragraphs;
}

/// Shared long-form layout for Terms of Service / Privacy Policy — a title,
/// a "last updated" date, an optional lead-in paragraph, then numbered
/// sections. Deliberately plainer than the rest of the app's card-heavy
/// style: a legal document reads better as continuous text than as a grid
/// of cards.
class LegalDocumentBody extends StatelessWidget {
  const LegalDocumentBody({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String lastUpdated;
  final String intro;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Last updated: $lastUpdated',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 24),
        FloatingCard(
          child: Text(intro, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7)),
        ),
        const SizedBox(height: 32),
        for (var i = 0; i < sections.length; i++) ...[
          Text(
            '${i + 1}. ${sections[i].heading}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          for (final paragraph in sections[i].paragraphs) ...[
            Text(
              paragraph,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.65, fontSize: 13),
            ),
            const SizedBox(height: 12),
          ],
          if (i != sections.length - 1) const SizedBox(height: 20),
        ],
      ],
    );
  }
}

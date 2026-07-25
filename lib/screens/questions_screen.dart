import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/help_content.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_card.dart';
import '../widgets/page_shell.dart';
import '../widgets/section_title.dart';

/// The full app SOP, organized as a searchable, categorized help center —
/// every category and question here describes something the app actually
/// does, sourced from the same real feature set as the rest of the UI
/// rather than written as separate marketing copy that could drift from
/// reality.
class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  int _selectedCategory = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final isSearching = query.isNotEmpty;

    final searchResults = <(HelpCategory, HelpQuestion)>[
      for (final category in helpCategories)
        for (final q in category.questions)
          if (q.question.toLowerCase().contains(query) || q.answer.toLowerCase().contains(query)) (category, q),
    ];

    return PageShell(
      pageTitle: 'Questions',
      builder: (context, isMobile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to dashboard'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const SectionTitle(
            label: 'Questions & guidance',
            subtitle: 'The full walkthrough of how PathFinder AI works, start to finish',
            color: AppColors.teal,
          ),
          const SizedBox(height: 24),
          _SearchField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 24),
          if (isSearching) ...[
            if (searchResults.isEmpty)
              const _EmptyState()
            else
              for (final (category, question) in searchResults)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _QuestionTile(question: question, categoryLabel: category.label, categoryColor: category.color),
                ),
          ] else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < helpCategories.length; i++)
                  _CategoryChip(
                    label: helpCategories[i].label,
                    icon: helpCategories[i].icon,
                    color: helpCategories[i].color,
                    selected: i == _selectedCategory,
                    onTap: () => setState(() => _selectedCategory = i),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            for (final question in helpCategories[_selectedCategory].questions)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _QuestionTile(question: question),
              ),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
        decoration: InputDecoration(
          hintText: 'Search anything — "delete account", "file types", "reminders"…',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          filled: true,
          fillColor: AppColors.surfaceCard,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.hairline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.hairline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.teal),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovering;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.color.withValues(alpha: 0.16)
                : (active ? AppColors.surfaceCardHover : AppColors.surfaceCard),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: widget.selected ? widget.color.withValues(alpha: 0.55) : AppColors.hairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: widget.selected ? widget.color : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.selected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionTile extends StatefulWidget {
  const _QuestionTile({required this.question, this.categoryLabel, this.categoryColor});

  final HelpQuestion question;
  final String? categoryLabel;
  final Color? categoryColor;

  @override
  State<_QuestionTile> createState() => _QuestionTileState();
}

class _QuestionTileState extends State<_QuestionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return FloatingCard(
      accentColor: widget.categoryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  if (widget.categoryLabel != null) ...[
                    Text(
                      widget.categoryLabel!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: widget.categoryColor ?? AppColors.teal,
                      ),
                    ),
                  ],
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: widget.categoryLabel != null ? 10 : 0),
                      child: Text(
                        widget.question.question,
                        style: const TextStyle(
                          fontFamily: AppTheme.displayFontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.expand_more, size: 20, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      widget.question.answer,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: const Text(
        'No matches — try a different word, or browse by category above.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
      ),
    );
  }
}

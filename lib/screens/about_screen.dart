import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/floating_card.dart';
import '../widgets/page_shell.dart';
import '../widgets/section_title.dart';
import '../widgets/social_links_row.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      pageTitle: 'About us',
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
          Text('About PathFinder AI', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'A clearer, calmer way to plan a move abroad.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 40),
          const SectionTitle(
            label: 'What we do',
            subtitle: 'The problem we\'re solving',
            color: AppColors.gold,
          ),
          const SizedBox(height: 20),
          FloatingCard(
            child: Text(
              'Skilled migration is confusing by design — requirements are scattered across '
              'government portals, assessing-authority PDFs, and forum threads, and they change '
              'without warning. PathFinder AI organizes your documents against your target '
              "occupation and country, surfaces the specific gaps between what you have and what's "
              'required, and turns that into a day-by-day action plan you can actually follow.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
            ),
          ),
          const SizedBox(height: 40),
          const SectionTitle(
            label: 'How we do it',
            subtitle: 'The process behind the dashboard',
            color: AppColors.teal,
          ),
          const SizedBox(height: 20),
          FloatingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HowStep(
                  number: '1',
                  title: 'Free eligibility diagnostic',
                  description:
                      'Tell us your occupation, target country, and upload your core documents. '
                      'We map that against known requirements for your pathway.',
                ),
                _HowStep(
                  number: '2',
                  title: 'Gap analysis',
                  description:
                      'Every discrepancy — a missing credit hour, a language band shortfall, an '
                      'unverified document — becomes a clearly explained gap, not a wall of jargon.',
                ),
                _HowStep(
                  number: '3',
                  title: 'Guided daily tasks',
                  description:
                      'Gaps convert into an ordered, trackable timeline: what to do next, why it '
                      'matters, and where to do it.',
                ),
                _HowStep(
                  number: '4',
                  title: 'Soft landing',
                  description:
                      'Once your pathway is on track, we surface practical next steps for '
                      'settling in — banking, health cover, and local logistics.',
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const SectionTitle(
            label: 'Collaborations',
            subtitle: 'Who we work with',
            color: AppColors.gold,
          ),
          const SizedBox(height: 20),
          FloatingCard(
            accentColor: AppColors.gold,
            child: Text(
              "We're building relationships with English-test centers, credential assessment "
              'bodies, and relocation service providers so the recommendations in your Soft '
              'Landing Hub come from vetted, relevant partners rather than generic listings. '
              "This network is still growing — we'll always be upfront in the app about which "
              'recommendations are partnered versus informational.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
            ),
          ),
          const SizedBox(height: 40),
          FloatingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('A note on advice', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Text(
                  'PathFinder AI is an organizational and informational tool — it helps you track '
                  'documents, understand publicly available requirements, and stay on top of your '
                  'own timeline. It is not a substitute for a licensed migration agent, immigration '
                  'lawyer, or the official guidance of the government body handling your '
                  'application.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
          if (hasAnySocialLinks) ...[
            const SizedBox(height: 40),
            const SectionTitle(
              label: 'Get in touch',
              subtitle: 'Follow along or reach out',
              color: AppColors.teal,
            ),
            const SizedBox(height: 20),
            const SocialLinksRow(),
          ],
        ],
      ),
    );
  }
}

class _HowStep extends StatelessWidget {
  const _HowStep({
    required this.number,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  final String number;
  final String title;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.tealSoft,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

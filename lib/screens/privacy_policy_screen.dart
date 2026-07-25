import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/legal_document.dart';
import '../widgets/page_shell.dart';

/// Placeholder legal entity/contact details — [COMPANY_NAME] hasn't been
/// decided yet (personal project vs. registered business). Replace every
/// occurrence before this is genuinely live, and have the result reviewed
/// by a lawyer before relying on it — this is a real, GDPR-informed draft
/// grounded in what the app actually does, not a substitute for legal
/// advice.
const _companyName = '[COMPANY NAME — TBD]';
const _contactEmail = '[privacy@yourdomain.example — TBD]';
const _jurisdiction = '[GOVERNING JURISDICTION — TBD]';
const _lastUpdated = '[DATE — set when this is actually published]';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      pageTitle: 'Privacy policy',
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
          const LegalDocumentBody(
            title: 'Privacy policy',
            lastUpdated: _lastUpdated,
            intro:
                'PathFinder AI ("we", "us") helps skilled migrants organize documents and track '
                'progress against occupational licensing requirements abroad. This policy explains '
                'what personal data we collect through the app, why, who we share it with, and the '
                'rights you have over it — written to the standard of the EU/UK General Data '
                'Protection Regulation (GDPR) regardless of where you\'re signing in from, because '
                'that\'s the strictest standard among the countries this app covers.',
            sections: [
              LegalSection(
                heading: 'Who we are',
                paragraphs: [
                  '$_companyName operates PathFinder AI. For any privacy question, request, or '
                      'complaint, contact us at $_contactEmail.',
                ],
              ),
              LegalSection(
                heading: 'What we collect',
                paragraphs: [
                  'Account data: your email address and password (your password is never stored '
                      'in readable form — authentication is handled by our infrastructure provider, '
                      'Supabase, using industry-standard hashing).',
                  'Profile data you choose to add: full name, phone number, date of birth, '
                      'nationality, country of residence, marital status, years of experience, '
                      'highest qualification, and a profile picture.',
                  'Pathway data: your target occupation and destination country, and your progress '
                      'through the associated checklist.',
                  'Documents you upload to satisfy a licensing or registration requirement — this '
                      'can include copies of passports, degrees, transcripts, language-test results, '
                      'and professional certificates. This is the most sensitive category of data '
                      'this app handles, and it is treated accordingly (see "How we protect your '
                      'data" below).',
                  'Usage data: which checklist items and tasks you\'ve completed, and a log of AI '
                      'review requests (what was analyzed and the result), so you can see your own '
                      'history and so we can audit the AI feature for accuracy.',
                  'A device push-notification token, only if you explicitly enable push '
                      'notifications.',
                ],
              ),
              LegalSection(
                heading: 'How we use it, and our legal basis',
                paragraphs: [
                  'To provide the core service — tracking your pathway, storing your documents, '
                      'and running the AI review you request — under the basis of contractual '
                      'necessity (we can\'t provide the service without this data).',
                  'To send you email or push notifications about your pathway (e.g. inactivity '
                      'reminders), only if you\'ve opted in — under the basis of your consent, which '
                      'you can withdraw at any time in Account Settings.',
                  'To maintain security, prevent abuse, and keep an audit trail of AI decisions — '
                      'under the basis of our legitimate interest in running a safe, accountable '
                      'service, balanced against your right to privacy.',
                ],
              ),
              LegalSection(
                heading: 'AI-assisted document review',
                paragraphs: [
                  'When you submit a document for review, its contents are sent to OpenAI\'s API to '
                      'extract visible fields (such as a name, a date, or a document type) for '
                      'comparison against the requirement you\'re satisfying. This processing is '
                      'governed by OpenAI\'s own API terms.',
                  'The AI extracts facts — it does not decide whether your document is acceptable. '
                      'Every result is provisional and clearly labeled as such in the app. No '
                      'automated system in this app makes a final decision about your eligibility, '
                      'your application, or your immigration outcome. That determination is made '
                      'solely by the relevant government body, licensing authority, or professional '
                      'you\'re working with. In line with the EU AI Act\'s transparency requirements, '
                      'we tell you clearly, before your first document review, that you\'re '
                      'interacting with an AI system — this isn\'t buried in a settings page.',
                  'This is treated as its own, specific consent, separate from agreeing to these '
                      'terms generally: the app asks you to explicitly agree to AI-assisted review '
                      'the first time you use it, and you can decline and use the app\'s '
                      'organizational features without it.',
                ],
              ),
              LegalSection(
                heading: 'Permissions this app requests',
                paragraphs: [
                  'Camera: only used when you choose to photograph a document or a profile picture. '
                      'We never access your camera without you actively initiating that action.',
                  'Photo library: only used when you choose to select an existing photo to upload.',
                  'Notifications: only requested if you turn on push notifications in Account '
                      'Settings — off by default. You can revoke this at any time, both in the app '
                      'and at the OS level.',
                  'None of these permissions are used for anything beyond the specific action you '
                      'took to trigger them — we don\'t access your camera roll, location, contacts, '
                      'or any other device data this app doesn\'t explicitly ask about here.',
                ],
              ),
              LegalSection(
                heading: 'Who we share data with',
                paragraphs: [
                  'We do not sell your personal data, ever. We share it only with the service '
                      'providers (sub-processors) that make the app work, each limited to what they '
                      'need to perform their specific function:',
                  '• Supabase — hosting, database, authentication, and file storage for everything '
                      'you save in the app.',
                  '• OpenAI — automated extraction from documents you submit for AI review.',
                  '• Google (Firebase Cloud Messaging) — delivering push notifications, only if you '
                      'enable them.',
                  '• Our transactional email provider — sending account and reminder emails, only if '
                      'you have email notifications enabled.',
                  'We do not voluntarily disclose your personal data — including your documents, '
                      'nationality, or immigration-related information — to any government agency. '
                      'We may disclose data where legally required to (such as a valid court order '
                      'or subpoena), and we\'ll notify you first unless legally prohibited from doing '
                      'so, or where necessary to protect the rights, safety, or property of '
                      'PathFinder AI, our users, or the public.',
                ],
              ),
              LegalSection(
                heading: 'International data transfers',
                paragraphs: [
                  'Our service providers operate infrastructure in multiple countries. Where your '
                      'data is transferred outside your own country or the European Economic Area, '
                      'we rely on the safeguards those providers offer (such as Standard Contractual '
                      'Clauses) to ensure it remains protected to a comparable standard.',
                ],
              ),
              LegalSection(
                heading: 'How long we keep your data',
                paragraphs: [
                  'We keep your data for as long as your account is active. If you delete your '
                      'account — a real, immediate, and irreversible action available in Account '
                      'Settings — your profile, pathway, uploaded documents, and associated records '
                      'are permanently deleted from our systems, not just hidden.',
                ],
              ),
              LegalSection(
                heading: 'Your rights',
                paragraphs: [
                  'Depending on where you live, you have the right to: access the personal data we '
                      'hold about you; correct it if inaccurate; request its deletion; restrict or '
                      'object to certain processing; receive a copy in a portable format; and '
                      'withdraw consent at any time where we rely on it. You can exercise most of '
                      'these directly in the app (Profile, Account Settings), or by contacting us at '
                      '$_contactEmail. If you\'re in the EU/UK, you also have the right to lodge a '
                      'complaint with your local data protection authority.',
                ],
              ),
              LegalSection(
                heading: 'Additional rights for California residents',
                paragraphs: [
                  'If you\'re a California resident, the CCPA/CPRA gives you the right to: know what '
                      'personal information we collect and why; delete it; correct it; opt out of '
                      'its sale or sharing; and limit use of sensitive personal information — with no '
                      'discrimination against you for exercising any of these.',
                  'We do not sell or share your personal information for cross-context behavioral '
                      'advertising, and we don\'t use advertising trackers of any kind — so there is '
                      'nothing to opt out of on that front. To exercise any other right, contact us '
                      'at $_contactEmail.',
                ],
              ),
              LegalSection(
                heading: 'How we protect your data',
                paragraphs: [
                  'Your data is protected by database-level access controls that restrict every '
                      'user to their own records, encrypted connections between the app and our '
                      'servers, and a private storage area for uploaded documents that only you can '
                      'read. No security measure is perfect, and we can\'t guarantee absolute '
                      'security — but we don\'t rely on secrecy of any kind for access control, only '
                      'on these enforced technical boundaries.',
                ],
              ),
              LegalSection(
                heading: 'Children\'s privacy',
                paragraphs: [
                  'PathFinder AI is not directed at, and is not intended for use by, children under '
                      '16. We do not knowingly collect data from children under that age.',
                ],
              ),
              LegalSection(
                heading: 'Cookies and local storage',
                paragraphs: [
                  'We use local browser/device storage to keep you signed in between visits. We do '
                      'not use third-party advertising trackers.',
                ],
              ),
              LegalSection(
                heading: 'Changes to this policy',
                paragraphs: [
                  'If we make a material change to this policy, we\'ll update the date above and, '
                      'where required, notify you directly.',
                ],
              ),
              LegalSection(
                heading: 'Contact us',
                paragraphs: [
                  'Questions, requests, or complaints about this policy or your data: $_contactEmail.',
                  'Governing jurisdiction: $_jurisdiction.',
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

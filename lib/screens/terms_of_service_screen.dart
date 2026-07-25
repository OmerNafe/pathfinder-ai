import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../widgets/legal_document.dart';
import '../widgets/page_shell.dart';

/// Same placeholder entity/contact details as privacy_policy_screen.dart —
/// see the note there. Replace before this is genuinely live, and have a
/// lawyer review the result.
const _companyName = '[COMPANY NAME — TBD]';
const _contactEmail = '[legal@yourdomain.example — TBD]';
const _jurisdiction = '[GOVERNING JURISDICTION — TBD]';
const _lastUpdated = '[DATE — set when this is actually published]';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      pageTitle: 'Terms of service',
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
            title: 'Terms of service',
            lastUpdated: _lastUpdated,
            intro:
                'These terms govern your use of PathFinder AI. By creating an account, you agree '
                'to them. Please read the sections on what this app is (and isn\'t) and the '
                'AI-assisted review disclaimer carefully — they matter more here than in most apps, '
                'because the decisions this app helps you organize can affect your ability to work '
                'in another country.',
            sections: [
              LegalSection(
                heading: 'What this service is',
                paragraphs: [
                  'PathFinder AI is an organizational and informational tool. It helps you track '
                      'documents, understand publicly available licensing and registration '
                      'requirements, and follow a self-directed timeline toward a target occupation '
                      'and country.',
                  'It is not legal advice, immigration advice, or a substitute for a licensed '
                      'migration agent, immigration lawyer, or the official guidance of the '
                      'government or professional body actually handling your application. Where '
                      'the app marks information as "directional" rather than "verified," that '
                      'means it has not been independently re-confirmed against a primary source — '
                      'always confirm requirements with the relevant official body before relying '
                      'on them.',
                ],
              ),
              LegalSection(
                heading: 'AI-assisted document review',
                paragraphs: [
                  'When you use the document review feature, an AI model extracts visible '
                      'information from what you upload and compares it against the requirement '
                      'you\'re satisfying. This result is provisional and assistive only. It can be '
                      'wrong, incomplete, or miss context a human reviewer would catch. It is never '
                      'a determination of whether your document will be accepted by any government '
                      'body, licensing authority, or employer, and you should not rely on it as one.',
                ],
              ),
              LegalSection(
                heading: 'Eligibility and your account',
                paragraphs: [
                  'You must be old enough to form a binding contract in your jurisdiction to create '
                      'an account. You agree to provide accurate information and to keep your '
                      'account credentials confidential. You\'re responsible for activity that '
                      'happens under your account.',
                ],
              ),
              LegalSection(
                heading: 'Acceptable use',
                paragraphs: [
                  'You agree not to: upload documents you know to be fraudulent or that don\'t '
                      'belong to you; impersonate another person; attempt to bypass or undermine the '
                      'app\'s security or access controls; or use the AI review feature in a way '
                      'designed to abuse, overload, or extract value from it outside its intended '
                      'purpose (reviewing your own documents against your own pathway).',
                ],
              ),
              LegalSection(
                heading: 'Your content',
                paragraphs: [
                  'You retain ownership of everything you upload. By uploading a document, you '
                      'grant us a limited license to store and process it solely to provide the '
                      'service back to you (including sending it to our AI review provider as '
                      'described in the Privacy Policy). We don\'t use your documents for any other '
                      'purpose, and we don\'t claim ownership of them.',
                ],
              ),
              LegalSection(
                heading: 'Intellectual property',
                paragraphs: [
                  'The PathFinder AI name, branding, and app design belong to $_companyName. '
                      'Nothing in these terms transfers any of that to you.',
                ],
              ),
              LegalSection(
                heading: 'Third-party information and partners',
                paragraphs: [
                  'Requirements and registry information reference third-party bodies (licensing '
                      'authorities, exam providers, etc.) for your convenience. We are not '
                      'affiliated with those bodies unless the app explicitly says a listing is '
                      'partnered. We\'re not responsible for the accuracy of external sites we link '
                      'to.',
                ],
              ),
              LegalSection(
                heading: 'Ending your use of the service',
                paragraphs: [
                  'You can delete your account at any time in Account Settings — this permanently '
                      'and immediately removes your data as described in the Privacy Policy. We may '
                      'suspend or terminate an account that violates these terms, particularly the '
                      'acceptable-use section above.',
                ],
              ),
              LegalSection(
                heading: 'Disclaimer of warranties',
                paragraphs: [
                  'The service is provided "as is," without warranty of any kind. We do not '
                      'guarantee that using this app will result in a successful license, '
                      'registration, or immigration outcome — those decisions are made entirely by '
                      'third parties outside our control.',
                ],
              ),
              LegalSection(
                heading: 'Limitation of liability',
                paragraphs: [
                  'To the maximum extent permitted by law, $_companyName is not liable for indirect, '
                      'incidental, or consequential damages arising from your use of the app, '
                      'including decisions made by a licensing body, employer, or immigration '
                      'authority in connection with information you organized using this app.',
                ],
              ),
              LegalSection(
                heading: 'Governing law',
                paragraphs: [
                  'These terms are governed by the laws of $_jurisdiction, without regard to '
                      'conflict-of-law principles.',
                ],
              ),
              LegalSection(
                heading: 'Changes to these terms',
                paragraphs: [
                  'If we make a material change, we\'ll update the date above and, where required, '
                      'notify you directly. Continuing to use the app after a change means you '
                      'accept the updated terms.',
                ],
              ),
              LegalSection(
                heading: 'Contact us',
                paragraphs: ['Questions about these terms: $_contactEmail.'],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

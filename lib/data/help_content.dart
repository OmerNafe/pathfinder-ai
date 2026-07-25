import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HelpQuestion {
  const HelpQuestion({required this.question, required this.answer});
  final String question;
  final String answer;
}

class HelpCategory {
  const HelpCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.questions,
  });
  final String label;
  final IconData icon;
  final Color color;
  final List<HelpQuestion> questions;
}

/// The full SOP for using PathFinder AI, organized the same way an
/// applicant actually moves through the app: sign up, set up a pathway,
/// upload documents, work through gaps and tasks, register with the real
/// licensing body, and manage the account along the way. Every answer
/// describes what the app actually does today — nothing here promises a
/// feature that isn't real.
final helpCategories = [
  HelpCategory(
    label: 'Getting started',
    icon: Icons.flag_outlined,
    color: AppColors.gold,
    questions: [
      HelpQuestion(
        question: 'How do I create an account?',
        answer:
            'On the sign-in page, switch to "Start your journey," enter your name, email, and a '
            'password, and agree to the Terms of Service and Privacy Policy. Depending on how '
            'the project is configured, you may be signed in immediately or asked to confirm '
            'your email first — if so, check your inbox for a confirmation link.',
      ),
      HelpQuestion(
        question: 'I confirmed my email — now what?',
        answer:
            'The confirmation page will show "Account verified successfully" with a button back '
            'to sign in. Sign in with the email and password you chose during setup.',
      ),
      HelpQuestion(
        question: 'What is a "pathway"?',
        answer:
            'Your pathway is your target occupation plus your target country — e.g. "Registered '
            'Nurse → Canada." Everything else in the app (documents, gaps, tasks, the licensing '
            'registry) is organized around this one pathway. You set it up right after signing '
            'up, and can change it later from the dashboard.',
      ),
      HelpQuestion(
        question: 'Can I change my occupation or destination country later?',
        answer: 'Yes — go to Edit Pathway from the dashboard to update either one at any time.',
      ),
    ],
  ),
  HelpCategory(
    label: 'Documents & AI review',
    icon: Icons.description_outlined,
    color: AppColors.teal,
    questions: [
      HelpQuestion(
        question: 'What file types can I upload?',
        answer:
            'PDF, JPG, PNG, and HEIC/HEIF (the format iPhones use for photos). Files must be '
            'under 15 MB. Anything else is rejected before it uploads, with a clear message '
            'explaining why.',
      ),
      HelpQuestion(
        question: 'How does AI document review actually work?',
        answer:
            'When you upload a document, it\'s sent to an AI model that reads what\'s visible on '
            'it — things like a name, a date, or a document type — and compares that against the '
            'requirement you\'re satisfying. The AI only extracts facts; it never decides whether '
            'your document will be accepted anywhere. Every result is clearly marked as '
            'provisional. The first time you upload, you\'ll be asked to explicitly agree to this '
            'AI processing — that\'s a one-time, separate consent from agreeing to the Terms.',
      ),
      HelpQuestion(
        question: 'What does "uncertain" mean as a review result?',
        answer:
            'It means the document was legible and processed, but the app doesn\'t yet have '
            'enough detail about the exact requirement (band scores, credit hours, etc.) to give '
            'a real pass/fail. This is deliberate — the app would rather say "uncertain" than '
            'guess and be wrong.',
      ),
      HelpQuestion(
        question: 'My document was marked "failed" — what do I do?',
        answer:
            'Check the reason shown on the document card. If it says the scan was too blurry, '
            'dark, or cropped, re-upload a clearer photo or scan. If it\'s a genuine processing '
            'error, try again — if it keeps failing, the AI review feature may not be fully '
            'configured yet on this deployment.',
      ),
      HelpQuestion(
        question: 'Can I remove or replace an uploaded document?',
        answer:
            'Yes — remove it from the Documents checklist and upload a new one for that same '
            'requirement. The old file is deleted from storage, not just hidden.',
      ),
      HelpQuestion(
        question: 'Is my document data used to train the AI model?',
        answer:
            'That depends on the AI provider\'s own policy, which is outside this app\'s control — '
            'see the Privacy Policy\'s AI-assisted document review section for the current '
            'answer.',
      ),
    ],
  ),
  HelpCategory(
    label: 'Gaps & tasks',
    icon: Icons.checklist_outlined,
    color: AppColors.amber,
    questions: [
      HelpQuestion(
        question: 'What is a "gap"?',
        answer:
            'A gap is a specific discrepancy between what you have and what your target '
            'occupation/country actually requires — e.g. an English test score that\'s one band '
            'below what\'s needed. Each gap is explained in plain language, not left as raw '
            'jargon.',
      ),
      HelpQuestion(
        question: 'How do tasks get created?',
        answer:
            'Gaps convert into ordered, trackable tasks — concrete next actions with an '
            'explanation of why each one matters. You work through them from the dashboard\'s '
            '"Today" card or the full Tasks list.',
      ),
      HelpQuestion(
        question: 'What do the task statuses (pending, verified, rejected) mean?',
        answer:
            'Pending means it\'s awaiting action or review. Verified means it\'s been confirmed '
            'complete. Rejected means something about it needs to be redone — check the status '
            'note on the task for the specific reason.',
      ),
    ],
  ),
  HelpCategory(
    label: 'Registration & licensing',
    icon: Icons.badge_outlined,
    color: AppColors.teal,
    questions: [
      HelpQuestion(
        question: 'What\'s the difference between the Registration Tracker and the Licensing Registry?',
        answer:
            'The Registration Tracker follows your own specific pathway step by step. The '
            'Licensing Registry is a broader, browsable reference — every occupation in a '
            'category, which body registers it, in every supported country — useful even before '
            'you\'ve settled on a final pathway.',
      ),
      HelpQuestion(
        question: 'What do the colored confidence markers mean?',
        answer:
            'Teal means verified against a primary source. Amber means directional — informative, '
            'but not independently re-checked, so confirm it with the official body before '
            'relying on it. Gray means confirmed not to be a regulated profession in that '
            'country.',
      ),
      HelpQuestion(
        question: 'How do I submit a licensing checklist?',
        answer:
            'Open a cell in the Licensing Registry that has a checklist icon, work through each '
            'step, then submit once everything is checked. You can edit and resubmit later if '
            'something changes.',
      ),
      HelpQuestion(
        question: 'Is PathFinder AI a substitute for a licensed immigration lawyer or migration agent?',
        answer:
            'No. This app is an organizational and informational tool — it helps you track '
            'documents and understand publicly available requirements. It is never a substitute '
            'for the official guidance of the government body handling your application, or for '
            'a licensed immigration professional.',
      ),
    ],
  ),
  HelpCategory(
    label: 'Certificates & sharing',
    icon: Icons.workspace_premium_outlined,
    color: AppColors.gold,
    questions: [
      HelpQuestion(
        question: 'What does "publish a certificate" do?',
        answer:
            'It creates a shareable, public link showing a snapshot of your real progress — which '
            'requirements are verified, pending, or rejected. It\'s a deliberate, one-time '
            'snapshot you choose to publish, not a live feed anyone could poll for real-time '
            'updates.',
      ),
      HelpQuestion(
        question: 'Can I update a certificate after publishing it?',
        answer:
            'Yes — publishing again overwrites the same link with your latest progress, so a link '
            'you already shared keeps working and just shows newer data.',
      ),
      HelpQuestion(
        question: 'Who can see my published certificate?',
        answer:
            'Anyone with the link — it\'s intentionally public, with no sign-in required, so it\'s '
            'easy to share with an employer or agent. It only ever shows what you explicitly '
            'published, never your live account data.',
      ),
    ],
  ),
  HelpCategory(
    label: 'Notifications',
    icon: Icons.notifications_outlined,
    color: AppColors.teal,
    questions: [
      HelpQuestion(
        question: 'How do I turn on email or push notifications?',
        answer:
            'Account Settings → Notifications. Push notifications will also ask your browser or '
            'device for permission — that request only appears after you turn the toggle on, '
            'never before.',
      ),
      HelpQuestion(
        question: 'What triggers a reminder?',
        answer:
            'Real inactivity on your pathway — you won\'t be messaged just for existing. Reminders '
            'only go to accounts that have opted in on that specific channel.',
      ),
      HelpQuestion(
        question: 'How do I stop notifications?',
        answer: 'Turn the relevant toggle off in Account Settings at any time — it takes effect immediately.',
      ),
    ],
  ),
  HelpCategory(
    label: 'Account & privacy',
    icon: Icons.privacy_tip_outlined,
    color: AppColors.danger,
    questions: [
      HelpQuestion(
        question: 'How do I change my profile picture?',
        answer: 'Profile menu → Change profile picture, or Profile → Picture directly.',
      ),
      HelpQuestion(
        question: 'How do I change my email address?',
        answer:
            'Edit it on the Profile screen — you\'ll get a confirmation link to your new address '
            'before the change actually takes effect, so your account can\'t be locked out by a '
            'typo.',
      ),
      HelpQuestion(
        question: 'How do I permanently delete my account?',
        answer:
            'Account Settings → Delete account. You\'ll need to type DELETE to confirm. This is '
            'real and immediate — your profile, pathway, uploaded documents, and every associated '
            'record are permanently removed, not just hidden.',
      ),
      HelpQuestion(
        question: 'Does PathFinder AI share my data with government agencies?',
        answer:
            'Not voluntarily — see the Privacy Policy for the full, exact commitment on this and '
            'the narrow legal circumstances where disclosure could be required.',
      ),
      HelpQuestion(
        question: 'Where can I read the full Terms of Service and Privacy Policy?',
        answer: 'Linked from the sign-in page footer, Account Settings → Legal, and the About page.',
      ),
    ],
  ),
  HelpCategory(
    label: 'Troubleshooting',
    icon: Icons.build_outlined,
    color: AppColors.amber,
    questions: [
      HelpQuestion(
        question: 'A document upload isn\'t working',
        answer:
            'Check the toast/error message that appears — most commonly it\'s an unsupported file '
            'type or a file over 15 MB. If neither applies and it still fails, try a different '
            'browser or a smaller version of the file, and confirm you\'re signed in.',
      ),
      HelpQuestion(
        question: 'A document is stuck on "reviewing"',
        answer:
            'This shouldn\'t happen — a real failure is always supposed to resolve to a "failed" '
            'status with a reason, never stay stuck indefinitely. If you see this, remove the '
            'document and re-upload it.',
      ),
      HelpQuestion(
        question: 'I never received a confirmation or reminder email',
        answer:
            'Check spam/junk first. If email notifications are enabled but nothing ever arrives, '
            'the email provider may not be fully configured on this deployment yet — this is a '
            'known, honestly-surfaced limitation rather than a silent failure.',
      ),
      HelpQuestion(
        question: 'The app is asking me to re-accept the Terms/Privacy Policy',
        answer:
            'This happens when the Terms of Service or Privacy Policy has been materially '
            'updated since you last agreed to them. Review the changes (linked right there) and '
            'accept again to continue — or sign out if you\'d rather not.',
      ),
      HelpQuestion(
        question: 'I can\'t find an answer here',
        answer: 'Reach out through the contact details on the Privacy Policy or Terms of Service page.',
      ),
    ],
  ),
];

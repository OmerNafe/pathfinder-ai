/// Directional processing-time ranges for the primary skilled-migration
/// pathway in each destination country — grounded in official/published
/// guidance looked up in July 2026 (IRCC, UK gov.uk, Australian Department
/// of Home Affairs, IND, USCIS, MOM Singapore, and others — see the note on
/// each entry). These are not a live-fetched feed and will drift out of
/// date; always confirm current processing times on the relevant
/// government portal before relying on this for a real decision. This
/// deliberately never produces a fabricated specific calendar date — only
/// a sourced range plus the applicant's own real document progress.
class ProcessingTimeEstimate {
  const ProcessingTimeEstimate({
    required this.programName,
    required this.minWeeks,
    required this.maxWeeks,
    required this.note,
  });

  final String programName;
  final int minWeeks;
  final int maxWeeks;
  final String note;

  String get rangeLabel {
    if (maxWeeks < 8) return '$minWeeks–$maxWeeks weeks';
    final minMonths = (minWeeks / 4.345).round();
    final maxMonths = (maxWeeks / 4.345).round();
    if (minMonths == maxMonths) return '~$minMonths month${minMonths == 1 ? '' : 's'}';
    return '$minMonths–$maxMonths months';
  }
}

const Map<String, ProcessingTimeEstimate> processingTimeEstimates = {
  'Canada': ProcessingTimeEstimate(
    programName: 'Express Entry',
    minWeeks: 26,
    maxWeeks: 30,
    note: "From application submission (e-APR) to decision, per IRCC's published service standard.",
  ),
  'Australia': ProcessingTimeEstimate(
    programName: 'Skilled visas (subclass 189/190/491)',
    minWeeks: 26,
    maxWeeks: 78,
    note: 'Varies widely by subclass and state nomination — 189 is fastest, 190 often slower. '
        'Excludes any wait time in the SkillSelect invitation pool.',
  ),
  'New Zealand': ProcessingTimeEstimate(
    programName: 'Accredited Employer Work Visa',
    minWeeks: 4,
    maxWeeks: 8,
    note: 'From a complete application being lodged, per Immigration New Zealand.',
  ),
  'Germany': ProcessingTimeEstimate(
    programName: 'EU Blue Card',
    minWeeks: 8,
    maxWeeks: 12,
    note: 'Combined embassy appointment and processing time once your documents are ready.',
  ),
  'United Kingdom': ProcessingTimeEstimate(
    programName: 'Skilled Worker visa',
    minWeeks: 3,
    maxWeeks: 8,
    note: 'From biometrics, once you hold a Certificate of Sponsorship — faster applying from '
        'outside the UK, slower from within.',
  ),
  'Netherlands': ProcessingTimeEstimate(
    programName: 'Highly Skilled Migrant (Kennismigrant)',
    minWeeks: 2,
    maxWeeks: 4,
    note: 'Via an IND-recognized sponsor — one of the fastest routes in this list. Longer '
        '(up to ~13 weeks) without a recognized sponsor.',
  ),
  'Ireland': ProcessingTimeEstimate(
    programName: 'Critical Skills Employment Permit',
    minWeeks: 4,
    maxWeeks: 8,
    note: 'Standard processing; Trusted Partner employers often see the faster end.',
  ),
  'Singapore': ProcessingTimeEstimate(
    programName: 'Employment Pass',
    minWeeks: 2,
    maxWeeks: 8,
    note: 'Online applications from a local entity are typically fastest; manual applications '
        'from overseas companies take longer.',
  ),
  'United States': ProcessingTimeEstimate(
    programName: 'H-1B / EB-2 NIW',
    minWeeks: 52,
    maxWeeks: 156,
    note: 'Highly variable by category and country of birth — this range reflects typical '
        'petition-to-decision timelines, not the full green card process for backlogged countries.',
  ),
  'United Arab Emirates': ProcessingTimeEstimate(
    programName: 'Employment visa',
    minWeeks: 2,
    maxWeeks: 5,
    note: 'Once your medical test and document attestation are complete.',
  ),
};

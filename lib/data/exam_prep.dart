/// English-language and professional-licensing exam guidance. Same honesty
/// convention as registration_bodies.dart: [verified] entries were checked
/// against an official/primary source in the July 2026 pass; unverified
/// entries rest on general research and should be treated as directional.
class ExamInfo {
  const ExamInfo({
    required this.acceptedTests,
    required this.note,
    this.verified = false,
    this.sourceNote,
  });

  final List<String> acceptedTests;
  final String note;
  final bool verified;
  final String? sourceNote;
}

/// English-language test guidance by destination country. Applies across
/// occupation categories (though some countries waive it for certain skill
/// levels, noted per entry).
const Map<String, ExamInfo> englishTestRequirements = {
  'Australia': ExamInfo(
    acceptedTests: ['IELTS', 'PTE Academic', 'TOEFL iBT', 'OET', 'Cambridge C1 Advanced'],
    note: 'Tiered by score: Competent English (IELTS 6 in each band), Proficient English '
        '(IELTS 7 in each band), and Superior English (IELTS 8 in each band) — higher '
        'tiers score more points toward your skilled visa.',
    verified: true,
    sourceNote: 'Confirmed against immi.homeaffairs.gov.au, Jul 2026.',
  ),
  'Canada': ExamInfo(
    acceptedTests: ['IELTS General Training', 'CELPIP General', 'PTE Core', 'TEF (French)'],
    note: 'Most Express Entry programs require Canadian Language Benchmark (CLB) 7+ '
        'across all four abilities. Note this is General Training, not IELTS Academic.',
    verified: true,
    sourceNote: 'Confirmed general framing (IRCC-related sources), Jul 2026.',
  ),
  'New Zealand': ExamInfo(
    acceptedTests: ['IELTS', 'TOEFL iBT', 'PTE Academic', 'Cambridge B2 First', 'OET'],
    note: 'Only required for roles at ANZSCO skill level 4–5 on the Accredited Employer '
        'Work Visa — most skill level 1–3 roles need no separate English test.',
    verified: true,
    sourceNote: 'Confirmed against immigration.govt.nz, Jul 2026.',
  ),
  'United Kingdom': ExamInfo(
    acceptedTests: ['IELTS for UKVI', 'PTE Academic UKVI', 'Trinity SELT'],
    note: 'A four-skills Secure English Language Test (SELT) is generally required for '
        'work visas.',
  ),
  'Germany': ExamInfo(
    acceptedTests: ['IELTS', 'TOEFL iBT'],
    note: 'English proficiency alone is often enough for English-speaking workplaces '
        'under the EU Blue Card — but German ability (often A1–B1) is commonly expected '
        'for daily life and some employers, and required for many regulated professions.',
  ),
  'Netherlands': ExamInfo(
    acceptedTests: ['IELTS', 'TOEFL iBT'],
    note: 'No single mandatory visa-linked test — most Kennismigrant employers assess '
        'English ability directly during hiring rather than requiring a certificate.',
  ),
  'Ireland': ExamInfo(
    acceptedTests: ['IELTS', 'TOEFL iBT'],
    note: 'Not required for nationals of majority English-speaking countries; otherwise '
        'assessed as part of your employment permit application.',
  ),
  'Singapore': ExamInfo(
    acceptedTests: ['IELTS', 'TOEFL iBT'],
    note: 'No standardised test tied to the Employment Pass — English ability is '
        'typically assessed through your qualification and interview.',
  ),
  'United States': ExamInfo(
    acceptedTests: ['IELTS', 'TOEFL iBT'],
    note: 'No standardised English test is required for H-1B — proficiency is assessed '
        'via your degree and the visa interview.',
  ),
  'United Arab Emirates': ExamInfo(
    acceptedTests: ['IELTS', 'TOEFL iBT'],
    note: 'No standardised visa-linked English test — employers assess proficiency '
        'directly.',
  ),
};

/// One section of the IELTS guide — a skill and a few concrete tips for it.
class IeltsGuideSection {
  const IeltsGuideSection({required this.title, required this.tips});

  final String title;
  final List<String> tips;
}

/// A real, named place to actually prepare — not a live directory, just a
/// curated starting point (same honesty convention as the rest of the app).
class ExamPrepResource {
  const ExamPrepResource({required this.name, required this.description, required this.url});

  final String name;
  final String description;
  final String url;
}

const String ieltsOverview =
    'IELTS scores you 0–9 across four skills — Listening, Reading, Writing, Speaking — '
    'then averages them into an Overall Band Score. Most skilled-visa and registration '
    'pathways set a minimum in EVERY band, not just the average, so one weak section can '
    'disqualify an otherwise strong result. Academic and General Training share the same '
    'Listening and Speaking tests but differ in Reading and Writing.';

const List<IeltsGuideSection> ieltsGuideSections = [
  IeltsGuideSection(
    title: 'Listening — 30 min + 10 min to transfer answers',
    tips: [
      'Four recordings, increasingly difficult: a conversation, a monologue, an academic '
          'discussion, then an academic lecture.',
      'Read each set of questions before its recording starts — you only hear it once.',
      'The answer is almost always a paraphrase of what you hear, not the exact wording.',
    ],
  ),
  IeltsGuideSection(
    title: 'Reading — 60 min',
    tips: [
      'Three passages, 40 questions. Academic uses denser, more scholarly texts than '
          'General Training.',
      'Skim for structure first, then hunt keywords for each question rather than reading '
          'linearly start to finish.',
      'True/False/Not Given trips up more candidates than any other question type — '
          'practise it specifically, not just general reading.',
    ],
  ),
  IeltsGuideSection(
    title: 'Writing — 60 min',
    tips: [
      'Task 1 (a graph/chart/process to describe for Academic, or a letter for General '
          'Training) is worth less than Task 2 — but still budget a full 20 minutes for it.',
      'Task 2 is a 250-word essay. Practise one clear structure — intro, two body points, '
          'conclusion — so you never run out of time mid-argument.',
      'Band 7+ needs a genuine range of sentence structures, not just correct grammar — '
          'overused memorised "template" phrases are actively penalised.',
    ],
  ),
  IeltsGuideSection(
    title: 'Speaking — 11–14 min',
    tips: [
      'Three parts: general questions, a 2-minute individual long turn on a cue card, then '
          'a two-way discussion on that same topic.',
      'Fluency and coherence matter more than accent — constant self-correction and long '
          'pauses cost more than a natural accent ever will.',
      'Record yourself answering old cue-card topics and play it back — most candidates '
          'underestimate how often they say "um."',
    ],
  ),
];

const List<ExamPrepResource> ieltsPrepResources = [
  ExamPrepResource(
    name: 'IELTS.org (official)',
    description: 'The official test body — sample tests, band descriptors, and results checking straight from the source.',
    url: 'https://ielts.org/',
  ),
  ExamPrepResource(
    name: 'British Council',
    description: 'Official test venues plus free preparation materials and practice tests.',
    url: 'https://www.britishcouncil.org/exam/ielts',
  ),
  ExamPrepResource(
    name: 'IDP IELTS',
    description: 'One of the three official test co-owners — booking, plus a free practice test platform.',
    url: 'https://ielts.idp.com/',
  ),
  ExamPrepResource(
    name: 'Cambridge English',
    description: 'The exam\'s content owner — official practice papers and preparation guidance.',
    url: 'https://www.cambridgeenglish.org/exams-and-tests/ielts/',
  ),
  ExamPrepResource(
    name: 'IELTS Liz',
    description: 'One of the most widely used independent prep sites — free model answers and section-by-section strategy.',
    url: 'https://ieltsliz.com/',
  ),
  ExamPrepResource(
    name: 'Magoosh IELTS',
    description: 'Structured video lessons and practice questions, with a well-regarded free study guide.',
    url: 'https://magoosh.com/ielts/',
  ),
];

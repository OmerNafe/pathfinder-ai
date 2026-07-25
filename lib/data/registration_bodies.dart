import 'document_requirements.dart';
import 'occupation_registration_ledger.dart';

/// The regulatory/registering body an applicant must (or may, for voluntary
/// professional titles) register with for a given destination country and
/// occupation category.
///
/// [verified] and [sourceNote] distinguish entries actually re-checked
/// against an official/primary source during the July 2026 rigorous
/// verification pass from entries still resting on the original general
/// research pass. Treat unverified entries as directional, not confirmed —
/// and treat verified entries as "confirmed as of the noted date," not
/// permanently accurate, since these rules do change. Always confirm with
/// the actual body before relying on this for a real application.
class RegistrationRequirement {
  const RegistrationRequirement({
    this.applicable = true,
    required this.bodyName,
    required this.bodyFullName,
    required this.description,
    this.mandatory = true,
    this.verified = false,
    this.sourceNote,
    this.steps,
    this.officialUrl,
  });

  /// False when no dedicated registering body exists for this combination
  /// (e.g. engineering in the Netherlands) — shown as a short note instead
  /// of a full registration card.
  final bool applicable;

  final String bodyName;
  final String bodyFullName;
  final String description;

  /// True if registration is required to practise or is required for the
  /// visa itself; false if it's a voluntary professional title.
  final bool mandatory;

  /// True only if this specific entry was re-checked against an official
  /// source during the July 2026 verification pass (see [sourceNote]).
  final bool verified;

  /// What was checked and where, for entries with [verified] true.
  final String? sourceNote;

  /// Ordered, applicant-facing to-do steps for this specific occupation,
  /// carried over when this requirement was sourced from the occupation-level
  /// ledger — null falls back to the generic step generator.
  final List<String>? steps;

  /// The registering body's own official site, when sourced from the
  /// occupation-level ledger.
  final String? officialUrl;
}

const Map<String, Map<OccupationCategory, RegistrationRequirement>> registrationRequirements = {
  'Australia': {
    OccupationCategory.healthcare: RegistrationRequirement(
      bodyName: 'AHPRA',
      bodyFullName: 'Australian Health Practitioner Regulation Agency',
      description: 'National registration required to practise. Nursing and midwifery '
          'applicants are also assessed by ANMAC for migration purposes — ANMAC is a '
          'migration document, not a clinical registration.',
      verified: true,
      sourceNote: 'Confirmed against ahpra.gov.au and anmac.org.au, Jul 2026.',
    ),
    OccupationCategory.engineering: RegistrationRequirement(
      bodyName: 'Engineers Australia',
      bodyFullName: 'Engineers Australia migration skills assessment (MSA)',
      description: 'A positive MSA outcome is mandatory for most skilled visas, '
          'regardless of state. Queensland (via BPEQ) and Victoria additionally require '
          'statutory registration to practise in prescribed areas of engineering.',
      verified: true,
      sourceNote: 'Confirmed against engineersaustralia.org.au, Jul 2026.',
    ),
    OccupationCategory.trades: RegistrationRequirement(
      bodyName: 'TRA',
      bodyFullName: 'Trades Recognition Australia',
      description: 'Migration skills assessment for trade occupations.',
    ),
    OccupationCategory.education: RegistrationRequirement(
      bodyName: 'AITSL + state authority',
      bodyFullName: 'AITSL skills assessment, then your state/territory Teacher '
          'Registration Authority (e.g. NESA, QCT, VIT, TRBWA, TRB SA, TRB Tasmania, '
          'ACT TQI, TRB NT)',
      description: 'AITSL assesses your qualification for the visa only — it gives no '
          "legal authority to teach. You separately register with the authority in the "
          'state or territory where you actually work; the Teachers\' Mutual Recognition '
          'framework then lets you transfer that registration between states.',
      verified: true,
      sourceNote: 'Confirmed against aitsl.edu.au and state authority sources, Jul 2026.',
    ),
    OccupationCategory.transport: RegistrationRequirement(
      bodyName: 'CASA',
      bodyFullName: 'Civil Aviation Safety Authority',
      description: 'License validation/conversion required to fly commercially in Australia.',
    ),
  },
  'Canada': {
    OccupationCategory.healthcare: RegistrationRequirement(
      bodyName: 'Provincial regulatory college',
      bodyFullName: 'e.g. College of Nurses of Ontario — varies by province',
      description: 'Licensing is provincial, not federal. NNAS (National Nursing '
          'Assessment Service) is the common first step for internationally educated '
          'nurses and issues an Advisory Report accepted by regulators in every province '
          'except Quebec and the territories — those have their own separate process.',
      verified: true,
      sourceNote: 'Confirmed against nnas.ca, Jul 2026.',
    ),
    OccupationCategory.engineering: RegistrationRequirement(
      bodyName: 'Provincial regulator',
      bodyFullName: 'e.g. PEO (Ontario), EGBC (British Columbia)',
      description: '"Engineer" is a protected title in Canada. Licensing is provincial; '
          'Engineers Canada coordinates mutual recognition between provinces.',
    ),
    OccupationCategory.trades: RegistrationRequirement(
      bodyName: 'Red Seal Program',
      bodyFullName: 'Interprovincial Standards Red Seal Program',
      description: 'National trade certification standard recognized across all '
          'provinces and territories.',
    ),
    OccupationCategory.education: RegistrationRequirement(
      bodyName: 'Provincial teaching certification body',
      bodyFullName: 'e.g. Ontario College of Teachers — varies by province',
      description: 'Education and teacher certification are provincial responsibilities in Canada.',
    ),
    OccupationCategory.transport: RegistrationRequirement(
      bodyName: 'Transport Canada',
      bodyFullName: 'Transport Canada Civil Aviation',
      description: 'License validation/conversion required to fly commercially in Canada.',
    ),
  },
  'New Zealand': {
    OccupationCategory.healthcare: RegistrationRequirement(
      bodyName: 'Responsible authority',
      bodyFullName: 'e.g. Nursing Council of New Zealand, Medical Council of New Zealand',
      description: 'Each health profession has its own responsible authority under the '
          'HPCA Act.',
    ),
    OccupationCategory.engineering: RegistrationRequirement(
      bodyName: 'Engineering New Zealand',
      bodyFullName: 'Engineering New Zealand (formerly IPENZ)',
      description: 'Chartered Professional Engineer (CPEng) is a voluntary, '
          'internationally-benchmarked competency mark — not required to work, but '
          'widely expected for senior roles.',
      mandatory: false,
      verified: true,
      sourceNote: 'Confirmed against engineeringnz.org, Jul 2026.',
    ),
    OccupationCategory.trades: RegistrationRequirement(
      bodyName: 'NZQA',
      bodyFullName: 'New Zealand Qualifications Authority',
      description: 'International qualification assessment for overseas trade qualifications.',
    ),
    OccupationCategory.education: RegistrationRequirement(
      bodyName: 'Teaching Council of Aotearoa NZ',
      bodyFullName: 'Teaching Council of Aotearoa New Zealand',
      description: 'Registration and a practising certificate are required to teach.',
    ),
    OccupationCategory.transport: RegistrationRequirement(
      bodyName: 'CAA NZ',
      bodyFullName: 'Civil Aviation Authority of New Zealand',
      description: 'License validation/conversion required to fly commercially in New Zealand.',
    ),
  },
  'Germany': {
    OccupationCategory.healthcare: RegistrationRequirement(
      bodyName: 'State authority (Approbation)',
      bodyFullName: 'e.g. Landesärztekammer for doctors — varies by Bundesland',
      description: 'Recognition (Anerkennung) is handled at state level; doctors need '
          'Approbation before practising.',
    ),
    OccupationCategory.engineering: RegistrationRequirement(
      bodyName: 'Ingenieurkammer',
      bodyFullName: 'State Chamber of Engineers (regional)',
      description: 'Only required to use the protected "Ingenieur" title or practise as '
          'a Consulting Engineer — most employed engineers work without it.',
      mandatory: false,
    ),
    OccupationCategory.trades: RegistrationRequirement(
      bodyName: 'IHK / HWK',
      bodyFullName: 'Chamber of Industry and Commerce / Chamber of Skilled Crafts',
      description: 'Handles recognition (Anerkennung) of foreign vocational qualifications.',
      verified: true,
      sourceNote: 'Confirmed against ihk.de and official chamber descriptions, Jul 2026.',
    ),
    OccupationCategory.education: RegistrationRequirement(
      bodyName: 'State Ministry of Education',
      bodyFullName: 'Landesministerium — varies by Bundesland',
      description: 'Teacher qualification recognition is handled at state level.',
    ),
    OccupationCategory.transport: RegistrationRequirement(
      bodyName: 'LBA',
      bodyFullName: 'Luftfahrt-Bundesamt',
      description: 'License validation/conversion required to fly commercially in Germany.',
    ),
  },
  'United Kingdom': {
    OccupationCategory.healthcare: RegistrationRequirement(
      bodyName: 'NMC / GMC',
      bodyFullName: 'Nursing and Midwifery Council (nurses/midwives) or General '
          'Medical Council (doctors)',
      description: 'Registration is mandatory to practise, via a Test of Competence '
          '(CBT + OSCE) for nurses. Other allied professions register with the HCPC.',
      verified: true,
      sourceNote: 'Confirmed against nmc.org.uk, Jul 2026.',
    ),
    OccupationCategory.engineering: RegistrationRequirement(
      bodyName: 'Engineering Council',
      bodyFullName: 'Via an institution, e.g. ICE, IMechE, IET',
      description: 'Chartered status is generally voluntary, though often expected for '
          'senior or consulting roles.',
      mandatory: false,
    ),
    OccupationCategory.trades: RegistrationRequirement(
      bodyName: 'UK ENIC',
      bodyFullName: 'UK National Information Centre for global qualifications',
      description: 'Compares your overseas trade qualification to the UK equivalent. '
          'Some trades (e.g. gas, electrical) have their own separate licensing schemes.',
      verified: true,
      sourceNote: 'Confirmed against enic.org.uk, Jul 2026.',
    ),
    OccupationCategory.education: RegistrationRequirement(
      bodyName: 'Teaching Regulation Agency',
      bodyFullName: 'Teaching Regulation Agency (England) — awards Qualified Teacher '
          'Status (QTS)',
      description: 'QTS recognition is required to teach in the maintained sector. From '
          'September 2026, newly recruited teachers must hold QTS or be actively working '
          'towards it.',
      verified: true,
      sourceNote: 'Confirmed against gov.uk (Teaching Regulation Agency guidance), Jul 2026.',
    ),
    OccupationCategory.transport: RegistrationRequirement(
      bodyName: 'UK CAA',
      bodyFullName: 'UK Civil Aviation Authority',
      description: 'License validation/conversion required to fly commercially in the UK.',
    ),
  },
  'Netherlands': {
    OccupationCategory.healthcare: RegistrationRequirement(
      bodyName: 'BIG-register',
      bodyFullName: 'BIG-register (Beroepen in de Individuele Gezondheidszorg)',
      description: 'Registration required to practise a regulated healthcare profession '
          'in the Netherlands.',
    ),
    OccupationCategory.engineering: RegistrationRequirement(
      applicable: false,
      bodyName: 'Not required',
      bodyFullName: '—',
      description: 'Engineering is an unregulated profession in the Netherlands — no '
          'licensing, registration, or work-experience requirement exists. KIVI is the '
          'national engineering association, but joining it is voluntary.',
      mandatory: false,
      verified: true,
      sourceNote: 'Confirmed against business.gov.nl and government sources, Jul 2026.',
    ),
    OccupationCategory.trades: RegistrationRequirement(
      bodyName: 'SBB',
      bodyFullName: 'Samenwerkingsorganisatie Beroepsonderwijs Bedrijfsleven',
      description: 'Credential evaluation for foreign vocational (VET) diplomas.',
      verified: true,
      sourceNote: 'Confirmed against s-bb.nl, Jul 2026.',
    ),
    OccupationCategory.education: RegistrationRequirement(
      bodyName: 'DUO',
      bodyFullName: 'Dienst Uitvoering Onderwijs',
      description: 'Diploma recognition/comparison for teaching qualifications.',
    ),
    OccupationCategory.transport: RegistrationRequirement(
      bodyName: 'ILT',
      bodyFullName: 'Inspectie Leefomgeving en Transport',
      description: 'License validation/conversion required to fly commercially in the '
          'Netherlands.',
    ),
  },
  'Ireland': {
    OccupationCategory.healthcare: RegistrationRequirement(
      bodyName: 'NMBI / Medical Council',
      bodyFullName: 'Nursing and Midwifery Board of Ireland (nurses/midwives) or '
          'Medical Council of Ireland (doctors)',
      description: 'Registration mandatory to practise.',
    ),
    OccupationCategory.engineering: RegistrationRequirement(
      bodyName: 'Engineers Ireland',
      bodyFullName: 'Engineers Ireland (Chartered Engineer title only)',
      description: 'Engineering is not a regulated profession in Ireland; Chartered '
          'Engineer status is a voluntary title, not a legal requirement to practise.',
      mandatory: false,
      verified: true,
      sourceNote: 'Confirmed against engineersireland.ie, Jul 2026 (moderate confidence — '
          'the official regulations describe the title process but don\'t explicitly '
          'state practice is unrestricted without it).',
    ),
    OccupationCategory.trades: RegistrationRequirement(
      bodyName: 'QQI (NARIC Ireland)',
      bodyFullName: 'Quality and Qualifications Ireland',
      description: 'Recognition/comparison of foreign vocational qualifications.',
      verified: true,
      sourceNote: 'Confirmed against qqi.ie, Jul 2026.',
    ),
    OccupationCategory.education: RegistrationRequirement(
      bodyName: 'Teaching Council of Ireland',
      bodyFullName: 'Teaching Council of Ireland',
      description: 'Registration required to teach in recognised schools.',
    ),
    OccupationCategory.transport: RegistrationRequirement(
      bodyName: 'IAA',
      bodyFullName: 'Irish Aviation Authority',
      description: 'License validation/conversion required to fly commercially in Ireland.',
    ),
  },
  'Singapore': {
    OccupationCategory.healthcare: RegistrationRequirement(
      bodyName: 'SNB / SMC',
      bodyFullName: 'Singapore Nursing Board (nurses) or Singapore Medical Council (doctors)',
      description: 'Registration mandatory to practise.',
    ),
    OccupationCategory.engineering: RegistrationRequirement(
      bodyName: 'PEB',
      bodyFullName: 'Professional Engineers Board',
      description: 'Mandatory for anyone supplying professional engineering services in '
          'the civil, electrical, mechanical, or chemical branches specifically — other '
          'engineering disciplines are not covered by PEB registration.',
      verified: true,
      sourceNote: 'Confirmed against peb.gov.sg, Jul 2026.',
    ),
    OccupationCategory.trades: RegistrationRequirement(
      applicable: false,
      bodyName: 'Not typically required',
      bodyFullName: '—',
      description: 'No dedicated foreign trade-qualification recognition body — your '
          'employer and the COMPASS framework assessment apply instead.',
      mandatory: false,
    ),
    OccupationCategory.education: RegistrationRequirement(
      bodyName: 'MOE',
      bodyFullName: 'Ministry of Education',
      description: 'Registration required to teach in Singapore schools.',
    ),
    OccupationCategory.transport: RegistrationRequirement(
      bodyName: 'CAAS',
      bodyFullName: 'Civil Aviation Authority of Singapore',
      description: 'License validation/conversion required to fly commercially in Singapore.',
    ),
  },
  'United States': {
    OccupationCategory.healthcare: RegistrationRequirement(
      bodyName: 'State licensing board',
      bodyFullName: 'e.g. state Board of Nursing or state Medical Board — varies by state',
      description: 'Licensing is state-based and requirements differ by state and can '
          'change without notice. CGFNS certification is the common first step for '
          'internationally educated nurses.',
      verified: true,
      sourceNote: 'Confirmed general state-based framing and CGFNS role against cgfns.org '
          'and a state medical board example, Jul 2026 — not every individual state '
          'checked.',
    ),
    OccupationCategory.engineering: RegistrationRequirement(
      bodyName: 'State PE board',
      bodyFullName: 'State Board of Professional Engineers (if applicable)',
      description: 'A Professional Engineer (PE) license is state-based and only '
          'required for engineers who sign off on public-facing work — most employed '
          "engineers don't need one.",
      mandatory: false,
    ),
    OccupationCategory.trades: RegistrationRequirement(
      bodyName: 'State licensing board',
      bodyFullName: 'Varies significantly by state and trade',
      description: 'No single national body; requirements differ by state.',
    ),
    OccupationCategory.education: RegistrationRequirement(
      bodyName: 'State Department of Education',
      bodyFullName: 'Varies by state',
      description: 'Teacher licensing is state-based in the US.',
    ),
    OccupationCategory.transport: RegistrationRequirement(
      bodyName: 'FAA',
      bodyFullName: 'Federal Aviation Administration',
      description: 'License validation/conversion required to fly commercially in the US.',
    ),
  },
  'United Arab Emirates': {
    OccupationCategory.healthcare: RegistrationRequirement(
      bodyName: 'DHA / DOH / MOHAP',
      bodyFullName: 'Dubai Health Authority (Dubai); Department of Health Abu Dhabi '
          '(Abu Dhabi & Al Ain); Ministry of Health and Prevention (Sharjah, Ajman, Umm '
          'Al Quwain, Ras Al Khaimah, Fujairah)',
      description: "Licensing authority depends on which emirate you'll work in — there "
          'is no single federal healthcare licensing body.',
      verified: true,
      sourceNote: 'Confirmed against mohap.gov.ae and doh.gov.ae, Jul 2026 — corrected '
          'from an earlier, less precise "MOH" label.',
    ),
    OccupationCategory.engineering: RegistrationRequirement(
      bodyName: 'Municipality registration',
      bodyFullName: 'e.g. Dubai Municipality — varies by emirate and discipline',
      description: 'Some engineering disciplines require local municipality '
          'registration to sign off on projects.',
      mandatory: false,
    ),
    OccupationCategory.trades: RegistrationRequirement(
      bodyName: 'MOHRE classification',
      bodyFullName: 'Ministry of Human Resources & Emiratisation',
      description: 'Trade/occupation classification for work permit purposes rather '
          'than a licensing exam.',
    ),
    OccupationCategory.education: RegistrationRequirement(
      bodyName: 'Federal TLS + emirate regulator',
      bodyFullName: 'Teacher Licensing System (federal), routed through KHDA (Dubai), '
          'ADEK (Abu Dhabi), SPEA (Sharjah), or the Ministry of Education (other emirates)',
      description: "Teacher licensing has a federal layer (TLS) plus an emirate-specific "
          'regulator for school appointments — which one applies depends on where '
          "you'll teach.",
      verified: true,
      sourceNote: 'Confirmed against u.ae official government guidance, Jul 2026 — '
          'corrected from an earlier "KHDA / ADEK only" framing that missed the federal '
          'TLS layer and Sharjah\'s SPEA.',
    ),
    OccupationCategory.transport: RegistrationRequirement(
      bodyName: 'GCAA',
      bodyFullName: 'General Civil Aviation Authority',
      description: 'License validation/conversion required to fly commercially in the UAE.',
    ),
  },
};

RegistrationRequirement? registrationRequirementFor(String country, OccupationCategory category) {
  return registrationRequirements[country]?[category];
}

/// The applicant-facing registration requirement for a specific occupation
/// and country: the occupation-level ledger entry when one has been
/// researched (the source of truth — see occupation_registration_ledger.dart,
/// since occupations within the same category often register with
/// completely different bodies, e.g. Medical Laboratory Scientist vs. Doctor
/// in Ireland), falling back to the broader category default only when no
/// occupation-specific entry exists.
RegistrationRequirement? registrationRequirementForOccupation(
  String occupation,
  String country,
  OccupationCategory category,
) {
  final ledgerEntry = ledgerEntryFor(occupation, country);
  if (ledgerEntry != null) return _fromLedgerEntry(ledgerEntry, country);
  return registrationRequirementFor(country, category);
}

RegistrationRequirement _fromLedgerEntry(LedgerEntry entry, String country) {
  final String description;
  if (!entry.applicable) {
    description = 'Not a licensed or registered profession in $country — no registration body applies.';
  } else if (entry.mandatory) {
    description = 'Registration with ${entry.body} is required to practise in $country.';
  } else {
    description = 'Registration with ${entry.body} is voluntary in $country — not legally required, '
        'though it may be professionally expected.';
  }

  return RegistrationRequirement(
    applicable: entry.applicable,
    bodyName: entry.body,
    bodyFullName: entry.note ?? '',
    description: description,
    mandatory: entry.mandatory,
    verified: entry.confidence == LedgerConfidence.verified,
    steps: entry.steps,
    officialUrl: entry.officialUrl,
  );
}

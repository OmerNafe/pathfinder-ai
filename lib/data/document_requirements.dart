/// Document requirement model powering the upload checklist. Structured in
/// three tiers — core (universal), country (destination-specific), and
/// occupation category (profession-specific) — rather than one exhaustive
/// per-country-per-occupation matrix. That would mean roughly 700 hand-authored
/// lists, most of them near-duplicates, and would be very easy to get subtly
/// wrong. The three-tier composition mirrors how real checklists work (a
/// general visa document list, plus separate professional/occupation
/// assessment paperwork) and is grounded in each country's official or
/// professional-body guidance — see the source notes below — but it is still
/// a directional synthesis, not a live regulatory feed. Always confirm
/// current requirements with the relevant government or licensing body.
class DocumentRequirement {
  const DocumentRequirement({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

/// Required for every pathway regardless of destination or occupation.
const List<DocumentRequirement> coreDocuments = [
  DocumentRequirement(
    id: 'core_passport',
    title: 'Passport (bio-data page)',
    description: "A clear scan or photo of your passport's photo/bio-data page.",
  ),
  DocumentRequirement(
    id: 'core_photo',
    title: 'Passport-size photograph',
    description: 'A recent passport-style photograph on a plain background.',
  ),
  DocumentRequirement(
    id: 'core_cv',
    title: 'Curriculum Vitae (CV)',
    description: 'Your current, up-to-date professional CV or resume.',
  ),
  DocumentRequirement(
    id: 'core_education_certificate',
    title: 'Highest educational certificate',
    description: 'The degree or diploma certificate for your highest qualification.',
  ),
  DocumentRequirement(
    id: 'core_transcript',
    title: 'Academic transcript',
    description: 'The official transcript or mark sheet accompanying your certificate.',
  ),
];

/// General visa/immigration document requirements by destination country.
/// Source: official government guidance (canada.ca, gov.uk, ind.nl, u.ae,
/// uscis.gov, immigration.govt.nz, immi.homeaffairs.gov.au, enterprise.gov.ie,
/// mom.gov.sg) and germany.info, cross-checked in July 2026.
const Map<String, List<DocumentRequirement>> countryDocumentRequirements = {
  'Canada': [
    DocumentRequirement(
      id: 'ca_language_test',
      title: 'Language test result (IELTS / CELPIP / TEF)',
      description: 'CLB 7+ in all four abilities for Express Entry eligibility.',
    ),
    DocumentRequirement(
      id: 'ca_eca',
      title: 'Educational Credential Assessment (ECA)',
      description: 'Required for any degree earned outside Canada.',
    ),
    DocumentRequirement(
      id: 'ca_proof_of_funds',
      title: 'Proof of settlement funds',
      description: 'Bank statements showing sufficient funds, unless exempt.',
    ),
    DocumentRequirement(
      id: 'ca_police_certificate',
      title: 'Police certificate(s)',
      description: 'From every country lived in for 6+ months since age 18.',
    ),
    DocumentRequirement(
      id: 'ca_employment_reference',
      title: 'Employment reference letters',
      description: 'Confirming role, duties, dates, and hours for claimed experience.',
    ),
  ],
  'Australia': [
    DocumentRequirement(
      id: 'au_skills_assessment',
      title: 'Skills assessment',
      description: 'A positive assessment from the relevant assessing authority for your occupation.',
    ),
    DocumentRequirement(
      id: 'au_english_test',
      title: 'English test result',
      description: 'Meeting at least Competent English for subclass 189/190/491.',
    ),
    DocumentRequirement(
      id: 'au_police_clearance',
      title: 'Police clearance certificate(s)',
      description: 'From every country lived in for 12+ months in the past 10 years since age 16.',
    ),
    DocumentRequirement(
      id: 'au_employment_evidence',
      title: 'Employment reference letters & payslips',
      description: 'Letterhead references plus at least two payslips per year claimed.',
    ),
    DocumentRequirement(
      id: 'au_birth_certificate',
      title: 'Birth certificate',
      description: 'Scanned colour copy of your birth certificate.',
    ),
  ],
  'New Zealand': [
    DocumentRequirement(
      id: 'nz_job_offer',
      title: 'Signed employment contract',
      description: 'A valid job offer from an INZ-accredited New Zealand employer.',
    ),
    DocumentRequirement(
      id: 'nz_medical',
      title: 'Medical exam / chest X-ray',
      description: 'Results from an approved panel physician, if requested by INZ.',
    ),
    DocumentRequirement(
      id: 'nz_photos',
      title: 'Visa-compliant photographs',
      description: 'Photographs meeting New Zealand visa photo specifications.',
    ),
    DocumentRequirement(
      id: 'nz_translations',
      title: 'Certified translations',
      description: 'For any documents not already in English.',
    ),
  ],
  'Germany': [
    DocumentRequirement(
      id: 'de_qualification_recognition',
      title: 'Qualification recognition proof',
      description: 'Anabin database "H+" printout or a ZAB Statement of Comparability.',
    ),
    DocumentRequirement(
      id: 'de_work_contract',
      title: 'Work contract or binding job offer',
      description: 'Meeting the applicable Blue Card / Chancenkarte salary threshold.',
    ),
    DocumentRequirement(
      id: 'de_health_insurance',
      title: 'Proof of health insurance',
      description: 'Valid German health insurance coverage.',
    ),
    DocumentRequirement(
      id: 'de_accommodation',
      title: 'Proof of accommodation',
      description: 'Evidence of a registered address in Germany.',
    ),
  ],
  'United Kingdom': [
    DocumentRequirement(
      id: 'uk_cos',
      title: 'Certificate of Sponsorship (CoS)',
      description: 'Issued by your licensed UK sponsor employer.',
    ),
    DocumentRequirement(
      id: 'uk_english_proof',
      title: 'English language proficiency proof',
      description: 'Approved test result or an exempt qualification.',
    ),
    DocumentRequirement(
      id: 'uk_funds',
      title: 'Proof of funds',
      description: '£1,270 held for 28 consecutive days, unless your sponsor certifies maintenance.',
    ),
    DocumentRequirement(
      id: 'uk_criminal_record',
      title: 'Criminal record certificate',
      description: 'Required for roles in education, healthcare, childcare, or social services.',
    ),
  ],
  'Netherlands': [
    DocumentRequirement(
      id: 'nl_sponsor_submission',
      title: 'Recognized sponsor employer submission',
      description: 'Your Dutch employer must be an IND-recognized sponsor and files on your behalf.',
    ),
    DocumentRequirement(
      id: 'nl_salary_proof',
      title: 'Salary contract proof',
      description: 'Fixed, guaranteed salary meeting the Kennismigrant threshold, paid to your own account.',
    ),
    DocumentRequirement(
      id: 'nl_civil_documents',
      title: 'Civil status documents',
      description: 'Marriage certificate or similar, legalized, if applicable.',
    ),
    DocumentRequirement(
      id: 'nl_health_insurance',
      title: 'Proof of health insurance',
      description: 'Valid Dutch health insurance coverage.',
    ),
  ],
  'Ireland': [
    DocumentRequirement(
      id: 'ie_salary_proof',
      title: 'Salary and contract details',
      description: 'Meeting the Critical Skills Employment Permit minimum remuneration.',
    ),
    DocumentRequirement(
      id: 'ie_qualification_docs',
      title: 'Degree, diploma, or trade qualification certificates',
      description: 'Evidence of the qualification required for the role.',
    ),
    DocumentRequirement(
      id: 'ie_employer_details',
      title: 'Employer detail form',
      description: 'Employer information required as part of the Employment Permits Online application.',
    ),
  ],
  'Singapore': [
    DocumentRequirement(
      id: 'sg_compass_docs',
      title: 'COMPASS supporting documents',
      description: 'Salary and qualification evidence for the COMPASS points framework.',
    ),
    DocumentRequirement(
      id: 'sg_translations',
      title: 'Certified English translations',
      description: 'Required for any documents not already in English.',
    ),
    DocumentRequirement(
      id: 'sg_regulatory_body',
      title: 'Regulatory body supporting documents',
      description: 'For regulated professions (medicine, nursing, law, etc.) only.',
    ),
  ],
  'United States': [
    DocumentRequirement(
      id: 'us_lca',
      title: 'Certified Labor Condition Application',
      description: 'Filed with the Department of Labor by your sponsoring employer (H-1B).',
    ),
    DocumentRequirement(
      id: 'us_credential_evaluation',
      title: 'Credential evaluation',
      description: 'Comparing your foreign degree to a US equivalent.',
    ),
    DocumentRequirement(
      id: 'us_experience_letters',
      title: 'Experience letters',
      description: 'Detailing role, duration, and responsibilities.',
    ),
    DocumentRequirement(
      id: 'us_immigration_history',
      title: 'Immigration history / I-94 records',
      description: 'If you have previously held US status.',
    ),
  ],
  'United Arab Emirates': [
    DocumentRequirement(
      id: 'ae_employment_contract',
      title: 'Employment contract',
      description: 'Signed contract with your UAE-based employer.',
    ),
    DocumentRequirement(
      id: 'ae_attested_qualifications',
      title: 'MOFA-attested qualification certificates',
      description: 'Educational/professional certificates attested by the UAE Ministry of Foreign Affairs.',
    ),
    DocumentRequirement(
      id: 'ae_medical_fitness',
      title: 'Medical fitness test results',
      description: 'Mandatory health screening for residence visa issuance.',
    ),
  ],
};

enum OccupationCategory {
  healthcare,
  engineering,
  technology,
  trades,
  education,
  science,
  business,
  transport,
}

const Set<String> _healthcareOccupations = {
  'Medical Doctor / Physician',
  'General Practitioner',
  'Specialized Surgeon',
  'Registered Nurse',
  'Medical Laboratory Scientist',
  'Pharmacist',
  'Physiotherapist',
  'Occupational Therapist',
  'Midwife',
  'Paramedic',
  'Clinical Psychologist',
  'Social Worker',
  'Senior Care Worker',
  'Geriatric Caregiver / Aged Care Worker',
  'Aged & Disability Support Worker',
  'Clinical Trial Manager',
};

const Set<String> _engineeringOccupations = {
  'Civil Engineer',
  'Mechanical Engineer',
  'Electrical Engineer',
  'Electronics Engineer',
  'Structural Engineer',
  'Chemical Engineer',
  'Mining Engineer',
  'Automotive Engineer',
  'Process Engineer',
  'Renewable Energy Technician',
  'Hardware / Silicon Engineer',
  'Robotics Specialist',
};

const Set<String> _technologyOccupations = {
  'Software Engineer',
  'Full-Stack Developer',
  'Data Scientist',
  'AI / Machine Learning Engineer',
  'AI Researcher',
  'Cybersecurity Specialist',
  'Cloud Architect',
  'Blockchain Architect',
  'Systems Analyst',
  'IT Business Analyst',
  'ICT Project Manager',
  'IT Consultant',
  'Telecommunications Technician',
};

const Set<String> _tradesOccupations = {
  'Electrician',
  'Industrial Electrician',
  'Plumber',
  'Carpenter',
  'Welder',
  'Metal Fitter',
  'Motor Mechanic',
  'Diesel Mechanic (Heavy Vehicle)',
  'Aircraft Mechanic',
  'HVAC Specialist',
  'Mechatronics Technician',
};

const Set<String> _educationOccupations = {
  'Early Childhood Teacher',
  'Primary School Teacher',
  'Secondary School Teacher',
  'Special Needs Teacher',
};

const Set<String> _scienceOccupations = {
  'Biological Scientist',
  'Biochemist',
  'Mathematician',
};

const Set<String> _businessOccupations = {
  'Accountant',
  'Senior Manager (Construction, Utilities & Transport)',
  'Construction Project Manager',
  'Quantity Surveyor',
  'Risk Manager',
  'Quantitative Analyst',
  'Quantitative Trader',
  'FinTech Compliance Expert',
  'Wealth Management Director',
  'Maritime Logistics Director',
  'Supply Chain Manager',
};

OccupationCategory occupationCategoryFor(String occupation) {
  if (_healthcareOccupations.contains(occupation)) return OccupationCategory.healthcare;
  if (_engineeringOccupations.contains(occupation)) return OccupationCategory.engineering;
  if (_technologyOccupations.contains(occupation)) return OccupationCategory.technology;
  if (_tradesOccupations.contains(occupation)) return OccupationCategory.trades;
  if (_educationOccupations.contains(occupation)) return OccupationCategory.education;
  if (_scienceOccupations.contains(occupation)) return OccupationCategory.science;
  if (_businessOccupations.contains(occupation)) return OccupationCategory.business;
  return OccupationCategory.transport;
}

/// Profession-specific assessment/registration paperwork by broad occupation
/// category. Source: professional-body guidance (CGFNS/nursing councils,
/// Engineers Australia migration skills assessment, Trades Recognition
/// Australia, AITSL teacher skills assessment), cross-checked in July 2026.
const Map<OccupationCategory, List<DocumentRequirement>> occupationCategoryDocumentRequirements = {
  OccupationCategory.healthcare: [
    DocumentRequirement(
      id: 'occ_health_good_standing',
      title: 'Certificate of good standing',
      description: 'From your home country professional/licensing board, confirming no disciplinary issues.',
    ),
    DocumentRequirement(
      id: 'occ_health_registration',
      title: 'Professional registration certificate',
      description: 'Current registration/license certificate from your state or national board.',
    ),
    DocumentRequirement(
      id: 'occ_health_credentialing',
      title: 'Credentialing organization certification',
      description: 'E.g. CGFNS, NBCOT, or FCCPT certification where applicable to your destination.',
    ),
  ],
  OccupationCategory.engineering: [
    DocumentRequirement(
      id: 'occ_eng_skills_assessment',
      title: 'Engineering skills assessment',
      description: 'A positive assessment from the relevant engineering assessing body.',
    ),
    DocumentRequirement(
      id: 'occ_eng_cdr',
      title: 'Competency Demonstration Report (CDR)',
      description: 'Required unless your degree is from an accredited Washington/Sydney/Dublin Accord program.',
    ),
  ],
  OccupationCategory.technology: [
    DocumentRequirement(
      id: 'occ_tech_reference_letters',
      title: 'Professional reference letters',
      description: 'From employers detailing your role, stack, and responsibilities.',
    ),
    DocumentRequirement(
      id: 'occ_tech_certifications',
      title: 'Relevant professional certifications',
      description: 'Cloud, security, or platform certifications, if you hold any relevant to the role.',
    ),
  ],
  OccupationCategory.trades: [
    DocumentRequirement(
      id: 'occ_trade_skills_assessment',
      title: 'Trade skills assessment',
      description: 'Practical/technical assessment against the relevant trade authority\'s standard.',
    ),
    DocumentRequirement(
      id: 'occ_trade_certificate',
      title: 'Trade certificate / apprenticeship completion',
      description: 'Evidence of trade qualification or completed apprenticeship.',
    ),
  ],
  OccupationCategory.education: [
    DocumentRequirement(
      id: 'occ_edu_skills_assessment',
      title: 'Teaching qualification skills assessment',
      description: 'A positive assessment from the relevant teaching authority.',
    ),
    DocumentRequirement(
      id: 'occ_edu_practicum',
      title: 'Supervised teaching practicum evidence',
      description: 'Proof of supervised classroom teaching practice completed during training.',
    ),
  ],
  OccupationCategory.science: [
    DocumentRequirement(
      id: 'occ_sci_reference_letters',
      title: 'Research/professional reference letters',
      description: 'From supervisors or employers detailing your research or lab experience.',
    ),
  ],
  OccupationCategory.business: [
    DocumentRequirement(
      id: 'occ_biz_reference_letters',
      title: 'Employment reference letters',
      description: 'Detailing seniority, scope, and responsibilities in your role.',
    ),
    DocumentRequirement(
      id: 'occ_biz_certifications',
      title: 'Professional certifications',
      description: 'E.g. CPA, CFA, or PMP, if applicable to your role.',
    ),
  ],
  OccupationCategory.transport: [
    DocumentRequirement(
      id: 'occ_transport_license',
      title: 'Professional license verification',
      description: 'E.g. commercial pilot license verified with the relevant aviation authority.',
    ),
    DocumentRequirement(
      id: 'occ_transport_medical',
      title: 'Medical fitness certificate',
      description: 'Aviation or transport-specific medical examination results.',
    ),
  ],
};

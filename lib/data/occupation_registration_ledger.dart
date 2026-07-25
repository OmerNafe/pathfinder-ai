import 'document_requirements.dart';

/// How confidently a [LedgerEntry] was checked. Same honesty convention as
/// registration_bodies.dart and exam_prep.dart, applied at occupation level
/// instead of category level — see the July 2026 occupation-granularity
/// research pass that replaced the category-only model for this hub.
enum LedgerConfidence { verified, directional, notRegulated }

/// One country's registration/licensing answer for one occupation.
class LedgerEntry {
  const LedgerEntry(
    this.body, {
    this.note,
    this.confidence = LedgerConfidence.directional,
    this.applicable = true,
    this.mandatory = true,
    this.steps,
    this.officialUrl,
  });

  final String body;
  final String? note;
  final LedgerConfidence confidence;

  /// False when no registration/licence of any kind exists for this
  /// occupation-country combination (e.g. Clinical Trial Manager everywhere,
  /// Care Worker roles in most countries) — mirrors
  /// [RegistrationRequirement.applicable] in registration_bodies.dart.
  final bool applicable;

  /// True if registration is required to practise; false for a voluntary
  /// professional title (e.g. Chartered Engineer via Engineers Ireland) —
  /// mirrors [RegistrationRequirement.mandatory].
  final bool mandatory;

  /// Ordered, applicant-facing to-do steps for actually registering with
  /// this body — only populated where independently researched (see the
  /// July 2026 registration-steps pass). Null means "not yet researched",
  /// not "no steps exist" — the UI must say so rather than show an empty list.
  final List<String>? steps;

  /// The registering body's own official site, only set where confirmed
  /// during that same research pass.
  final String? officialUrl;
}

/// One occupation row, keyed by the same country name strings used in
/// [targetCountryOptions] elsewhere in the app.
class OccupationLedgerRow {
  const OccupationLedgerRow({required this.occupation, required this.byCountry});

  final String occupation;
  final Map<String, LedgerEntry> byCountry;
}

// ---------------------------------------------------------------------
// Healthcare
// ---------------------------------------------------------------------

/// Shared across Doctor/GP/Surgeon — all three register with the same body
/// via the same process in every one of our ten countries; only the note
/// (specialist/vocational add-ons) differs.
final Map<String, LedgerEntry> _doctorEntries = {
  'Canada': const LedgerEntry(
    'College of Physicians & Surgeons',
    note: 'per province, e.g. CPSO',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://mcc.ca/credentials-and-services/pathways-to-licensure/pathways-for-international-medical-graduates/',
    steps: [
      'Create a PhysiciansApply.ca account (the MCC\'s document-verification portal)',
      'Submit a Source Verification Request for your medical degree and pay the fee',
      'Demonstrate English or French language proficiency',
      'Apply for and sit the MCCQE at a Prometric centre within your 12-month eligibility window',
      'Obtain your LMCC (Licentiate of the Medical Council of Canada) after passing',
      'Apply to the medical regulatory authority in the province/territory where you intend to practise',
    ],
  ),
  'Australia': const LedgerEntry(
    'Medical Board of Australia',
    note: 'under AHPRA',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www.amc.org.au/pathways/',
    steps: [
      'Determine your AMC pathway (Standard, Competent Authority, or Specialist)',
      'Create an AMC portfolio and a MyIntealth (ECFMG/EPIC) account for primary source verification of your degree',
      'Confirm your medical school is listed in the World Directory of Medical Schools with an AMC-recognised note',
      'Sit and pass the AMC Computer Adaptive Test (knowledge)',
      'Sit and pass the AMC Clinical Examination',
      'Apply for registration with AHPRA (the Medical Board of Australia) — AMC itself doesn\'t grant registration',
    ],
  ),
  'New Zealand': const LedgerEntry(
    'Medical Council of NZ',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www.mcnz.org.nz/registration/getting-registered/',
    steps: [
      'Confirm your qualification is in the World Directory of Medical Schools and you have 1+ year of postgraduate experience',
      'Verify your documents via ECFMG\'s EPIC service through the MyIntealth portal',
      'Take an approved English proficiency test',
      'Sit and pass the NZREX Clinical exam, unless eligible via another pathway',
      'Secure a PGY1 job offer at an MCNZ-accredited hospital',
      'Apply for Provisional General Registration, then complete 12 months of supervised prevocational training',
    ],
  ),
  'Germany': const LedgerEntry(
    'Approbation',
    note: 'via state Landesärztekammer',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www.anerkennung-in-deutschland.de/',
    steps: [
      'Contact the Approbationsbehörde (licensing authority) for the state where you plan to work',
      'Submit your qualification documents for an equivalency assessment',
      'Reach C1-level medical German and pass the Fachsprachprüfung (medical language exam)',
      'If not automatically equivalent, sit the Kenntnisprüfung (medical knowledge exam)',
      'Receive your Approbation — full, unrestricted medical licence',
    ],
  ),
  'United Kingdom': const LedgerEntry(
    'GMC',
    note: 'General Medical Council',
    confidence: LedgerConfidence.verified,
    officialUrl:
        'https://www.gmc-uk.org/registration-and-licensing/join-our-registers/registration-applications/application-guides/full-registration-for-international-medical-graduates',
    steps: [
      'Confirm your primary medical qualification meets GMC criteria',
      'Meet the GMC\'s English language requirement',
      'Sit and pass PLAB Part 1 (multiple-choice) and PLAB Part 2 (OSCE), usually within 2 years of each other',
      'Have your qualification verified by ECFMG (EPIC)',
      'Submit your registration application via GMC Online',
      'Complete any required internship/foundation-equivalent period, then receive full registration',
    ],
  ),
  'Netherlands': const LedgerEntry(
    'BIG-register',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://english.bigregister.nl/',
    steps: [
      'Use the Advice Wizard to identify which of the 3 recognition procedures applies to your diploma',
      'Submit your application for recognition of your foreign medical diploma',
      'Reach the required Dutch language level',
      'Wait for the recognition decision — up to 12 weeks',
      'Once recognised, apply for mandatory BIG registration',
    ],
  ),
  'Ireland': const LedgerEntry(
    'Medical Council of Ireland',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www.medicalcouncil.ie/registration/',
    steps: [
      'Identify the correct IMC registration division for your circumstances',
      'Verify your primary medical qualification via ECFMG\'s EPIC platform — IMC only accepts credentials shared directly through EPIC',
      'Meet the English requirement (IELTS 7.0 overall, 6.5 in each module, or equivalent)',
      'Submit your application with notarised passport and qualification documents',
      'Complete any knowledge/skills tests the IMC specifies',
      'Attend an ID check and receive your IMC registration number',
    ],
  ),
  'Singapore': const LedgerEntry(
    'SMC',
    note: 'Singapore Medical Council',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www.smc.gov.sg/for-professionals/apply-for-registration/',
    steps: [
      'Secure an employment offer from an SMC-approved healthcare institution first',
      'Confirm your medical qualification is on SMC\'s recognised list',
      'Upload documents to EPIC for primary source verification',
      'Submit your registration application to the SMC',
      'Begin under Conditional Registration — supervised practice for at least 2 years',
    ],
  ),
  'United States': const LedgerEntry(
    'State Medical Board',
    note: 'varies by state',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www.ecfmg.org/certification/',
    steps: [
      'Confirm your medical school is ECFMG-recognised in the World Directory',
      'Submit your Application for ECFMG Certification via the MyIntealth portal',
      'Pass USMLE Step 1 and Step 2 CK',
      'Complete an ECFMG-approved pathway for clinical/communication skills (e.g. OET Medicine)',
      'Have your final diploma verified directly with your medical school',
      'Apply to your chosen State Medical Board and sit any remaining state-specific requirements',
    ],
  ),
  'United Arab Emirates': const LedgerEntry(
    'DHA / DOH / MOHAP',
    note: 'by emirate',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://services.dha.gov.ae/',
    steps: [
      'Check eligibility via the DHA Sheryan portal\'s assessment tool (or the DOH/MOHAP equivalent for your emirate)',
      'Complete your professional profile: education, clinical experience, home-country licence, good-standing certificate',
      'Submit documents for DataFlow primary-source verification',
      'Sit the DHA Prometric exam if required for your specialty',
      'Secure an employer to activate your licence in Sheryan',
    ],
  ),
};

final _doctorRow = OccupationLedgerRow(occupation: 'Medical Doctor / Physician', byCountry: _doctorEntries);

LedgerEntry _sameAsDoctor(String country, String? extraNote) {
  final base = _doctorEntries[country]!;
  return LedgerEntry(
    'Same as Doctor',
    note: extraNote,
    confidence: LedgerConfidence.verified,
    officialUrl: base.officialUrl,
    steps: base.steps,
  );
}

final _gpRow = OccupationLedgerRow(
  occupation: 'General Practitioner',
  byCountry: {
    'Canada': _sameAsDoctor('Canada', 'same statutory register; no separate GP body'),
    'Australia': _sameAsDoctor('Australia', 'plus RACGP/ACRRM vocational recognition for Medicare billing'),
    'New Zealand': _sameAsDoctor('New Zealand', null),
    'Germany': _sameAsDoctor('Germany', null),
    'United Kingdom': _sameAsDoctor('United Kingdom', 'plus the GP Register via RCGP'),
    'Netherlands': _sameAsDoctor('Netherlands', null),
    'Ireland': _sameAsDoctor('Ireland', null),
    'Singapore': _sameAsDoctor('Singapore', null),
    'United States': _sameAsDoctor('United States', null),
    'United Arab Emirates': _sameAsDoctor('United Arab Emirates', null),
  },
);

final _surgeonRow = OccupationLedgerRow(
  occupation: 'Specialized Surgeon',
  byCountry: {
    'Canada': _sameAsDoctor('Canada', 'plus specialty certification'),
    'Australia': _sameAsDoctor('Australia', 'plus specialist registration via RACS assessment'),
    'New Zealand': _sameAsDoctor('New Zealand', null),
    'Germany': _sameAsDoctor('Germany', null),
    'United Kingdom': _sameAsDoctor('United Kingdom', 'plus the GMC Specialist Register'),
    'Netherlands': _sameAsDoctor('Netherlands', null),
    'Ireland': _sameAsDoctor('Ireland', null),
    'Singapore': _sameAsDoctor('Singapore', null),
    'United States': _sameAsDoctor('United States', null),
    'United Arab Emirates': _sameAsDoctor('United Arab Emirates', null),
  },
);

const _nurseRow = OccupationLedgerRow(
  occupation: 'Registered Nurse',
  byCountry: {
    'Canada': LedgerEntry(
      'Provincial nursing college',
      note: 'NNAS is the common first step',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.nnas.ca/',
      steps: [
        'Create an NNAS online account and enter your education and work history',
        'Submit required documents (transcripts, registration/licensure verification) for NNAS to verify directly with your issuing institutions',
        'Wait for document verification — typically several weeks to a few months',
        'Receive your NNAS Advisory Report',
        'Apply to your chosen provincial regulatory body (e.g. College of Nurses of Ontario) using the Advisory Report',
        'Meet that province\'s own remaining requirements (English test, jurisprudence exam) — Quebec and the territories run a separate process outside NNAS',
      ],
    ),
    'Australia': LedgerEntry(
      'Nursing & Midwifery Board',
      note: 'under AHPRA',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.ahpra.gov.au/',
      steps: [
        'Confirm your qualification and English test result meet ANMAC/NMBA requirements',
        'Apply to ANMAC (anmac.org.au) for a skills assessment — required for most skilled visas',
        'Create an account in AHPRA Online Services and apply via the Internationally Qualified Nurse pathway',
        'Submit certified documents: qualification, registration status, identity, English test',
        'Complete an Outcome-Based Assessment (OBA) bridging program if required',
        'Receive AHPRA registration, then apply for the relevant visa',
      ],
    ),
    'New Zealand': LedgerEntry(
      'Nursing Council of NZ',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.nursingcouncil.org.nz/',
      steps: [
        'Use the Nursing Council\'s self-assessment tool to check whether a competence assessment is required',
        'Verify and authenticate your documents through TruMerit before applying to the Council',
        'Once invited by the Council, submit your registration application',
        'If required, sit the online multiple-choice competence exam at a Pearson VUE centre',
        'Complete the in-person OSCE at the Nurse Maude Simulation & Assessment Centre in Christchurch',
        'Complete the free "Welcome to Aotearoa New Zealand" online orientation programme',
        'Receive registration and an Annual Practising Certificate',
      ],
    ),
    'Germany': LedgerEntry(
      'Anerkennung',
      note: 'regional authority',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.anerkennung-in-deutschland.de/',
      steps: [
        'Use the Recognition Finder tool to identify the competent authority (Bezirksregierung) for your state',
        'Submit your application for recognition as a nursing specialist (Pflegefachperson) with certified documents',
        'Reach at least A2 German to apply — B2 is generally needed for full, unrestricted practice',
        'If not automatically equivalent, complete a compensatory measure: an adaptation period (up to 3 years) or a knowledge examination',
        'Receive written confirmation of recognition and permission to use the professional title',
      ],
    ),
    'United Kingdom': LedgerEntry(
      'NMC',
      note: 'Nursing and Midwifery Council',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.nmc.org.uk/registration/joining-the-register/',
      steps: [
        'Confirm you hold an unrestricted nursing licence in your country of qualification',
        'Meet the English requirement (e.g. IELTS Academic 7.0 overall, 6.5 writing, or equivalent OET)',
        'Submit your application and documents, and pay the evaluation fee',
        'Sit and pass the Computer-Based Test (CBT) at a Pearson VUE centre',
        'Sit and pass the Objective Structured Clinical Examination (OSCE) at an approved UK test centre',
        'Submit your final registration application and fee to receive your NMC PIN',
      ],
    ),
    'Netherlands': LedgerEntry(
      'BIG-register',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://english.bigregister.nl/',
      steps: [
        'Use the Advice Wizard on the BIG-register site to identify which recognition procedure applies to your diploma',
        'Submit your application for recognition of your foreign diploma via mijn.bigregister.nl',
        'Reach the Dutch language level expected for your role — near-mandatory in practice',
        'Wait for the recognition decision — up to 12 weeks',
        'Once recognised, submit your application for BIG registration itself',
      ],
    ),
    'Ireland': LedgerEntry(
      'NMBI',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.nmbi.ie/Registration/Qualified-outside-the-EU',
      steps: [
        'Confirm your qualification is equivalent to Irish nursing education standards',
        'Download and submit the Overseas Application Request Form from nmbi.ie',
        'Pay the assessment cost and receive your Overseas Registration Application Pack',
        'Submit required documentation: nursing degree, home-country licence, transcripts, English test (IELTS/OET)',
        'Await NMBI\'s assessment and registration decision — typically 3–6 months',
      ],
    ),
    'Singapore': LedgerEntry(
      'SNB',
      note: 'Singapore Nursing Board',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.snb.gov.sg/for-professionals/becoming-a-nurse-or-midwife/apply-for-registration-enrolment/foreign-trained-nurses-midwives/',
      steps: [
        'Secure a job offer from an eligible Singapore healthcare institution first — SNB will not process an application without one',
        'Have your employer\'s HR team confirm your eligibility with SNB',
        'Your employer\'s HR submits the registration/enrolment application to SNB on your behalf',
        'Provide verification of registration and standing from every country where you\'ve practised',
        'Complete any required licensure examination and competency assessment',
        'Receive provisional, then full, registration/enrolment',
      ],
    ),
    'United States': LedgerEntry(
      'State Board of Nursing',
      note: 'CGFNS + NCLEX-RN',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.cgfns.org/',
      steps: [
        'Confirm you hold a current, unrestricted nursing licence in your country of education',
        'Apply for the CGFNS Certification Program via the CGFNS Connect Portal — required by about two-thirds of state boards',
        'Have your nursing licence verification sent directly to CGFNS by your home country\'s licensing body',
        'Sit the CGFNS Qualifying Exam',
        'Request your certification verification letter be sent to your chosen State Board of Nursing',
        'Meet that state\'s remaining requirements and sit the NCLEX-RN',
        'Receive your state nursing licence',
      ],
    ),
    'United Arab Emirates': LedgerEntry(
      'DHA / DOH / MOHAP',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://services.dha.gov.ae/',
      steps: [
        'Create an account on the DHA Sheryan portal (or the DOH/MOHAP equivalent for your emirate)',
        'Submit documents for DataFlow primary-source verification (degree, licence, good-standing letter, experience letters)',
        'Once DataFlow is approved, apply for your Eligibility Certificate via Sheryan',
        'Sit and pass the DHA Prometric licensing exam for nurses',
        'Secure a job offer — your hiring facility activates your professional licence in Sheryan on your behalf',
      ],
    ),
  },
);

const _medLabScientistRow = OccupationLedgerRow(
  occupation: 'Medical Laboratory Scientist',
  byCountry: {
    'Canada': LedgerEntry(
      'Provincial MLT college',
      note: 'not regulated in BC, PEI, territories',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://csmls.org/certification/how-to-become-certified/internationally-educated-medical-laboratory-technologists-iemlt/',
      steps: [
        'Request a Prior Learning Assessment (PLA) from CSMLS — evaluates academic credentials, clinical training, and language proficiency (averages ~18 months)',
        'Receive a Statement of Eligibility for the CSMLS national certification exam',
        'Register for the exam and pay the fee',
        'Schedule and sit the exam at a Prometric centre in Canada',
        'Submit your certification result to your provincial college (e.g. CMLTA) to move from provisional to full registration',
      ],
    ),
    'Australia': LedgerEntry('Not registered', note: 'AIMS membership is voluntary; migration uses a skills assessment instead', confidence: LedgerConfidence.verified, applicable: false),
    'New Zealand': LedgerEntry(
      'Medical Sciences Council of NZ',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.mscouncil.org.nz/pre-registration/overseas-trained-how-to-register/overseas-trained-registration-medical-laboratory-scientist',
      steps: [
        'Gather certified qualification certificates, transcripts, certificates of good character/standing, passport ID page, and police checks',
        'Meet the English requirement — IELTS 7.0 in each band, or OET B pass (pharmacy or medicine test)',
        'Create a profile with the Council, complete the application form, and pay the fee',
        'Await assessment — up to 12 weeks if a full qualification assessment is needed',
        'Once registered, complete 3–24 months of supervised practice under provisional registration',
      ],
    ),
    'Germany': LedgerEntry('Anerkennung as MTLA', note: 'regional authority', confidence: LedgerConfidence.verified, officialUrl: _germanAnerkennungUrl, steps: _germanAnerkennungSteps),
    'United Kingdom': LedgerEntry(
      'HCPC',
      note: 'as Biomedical Scientist',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.hcpc-uk.org/registration/getting-on-the-register/international-applications/',
      steps: [
        'Confirm your degree and clinical training are equivalent to a UK BSc (Hons) in Biomedical Science, across haematology, clinical chemistry, microbiology, histology, and blood banking',
        'Complete the International Application Route registration form on the HCPC website',
        'Certify and upload all documents as high-quality colour scans — the HCPC uses fraud-detection screening',
        'Pay the non-refundable Scrutiny Fee at submission',
        'Once approved, pay the registration fee to be added to the register',
      ],
    ),
    'Netherlands': LedgerEntry(
      'Not BIG-registered',
      note: '"analist" requires national authorization to work in hospital labs, but sits outside the mandatory BIG-register list',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://business.gov.nl/regulations/registering-as-healthcare-professional/',
      steps: [
        'Confirm your qualification matches one of the recognised bachelor programs for "analist" authorization',
        'Apply for national authorization to work in a Dutch hospital laboratory — separate from BIG registration',
        'Reach the required Dutch language level for your workplace',
      ],
    ),
    'Ireland': LedgerEntry(
      'CORU',
      note: 'as Medical Scientist',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.coru.ie/health-and-social-care-professionals/registration/international-applicants/how-to-apply/',
      steps: [
        'Read CORU\'s general guidance notes and processing timelines',
        'Read the Standards of Proficiency and placement criteria for Medical Scientists',
        'Apply via CORU\'s online recognition system (or the Recognition Application Form)',
        'Upload documents evidencing your qualification, training, and work experience against the Standards of Proficiency',
        'Complete eVetting with the National Vetting Bureau',
        'Await the recognition decision — up to 4 months once your file is complete',
      ],
    ),
    'Singapore': LedgerEntry(
      'HSA',
      note: 'Health Sciences Authority — not AHPC',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.hsa.gov.sg/',
      steps: [
        'Hold a recognised Bachelor of Science in medical technology, clinical laboratory science, or a related field',
        'Secure employment with a Singapore healthcare institution',
        'Register with the Health Sciences Authority to meet its competency standards',
      ],
    ),
    'United States': LedgerEntry(
      'Varies by state',
      note: 'license mandatory in ~13 states only; ASCP/AMT cert elsewhere',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.ascp.org/boc/explore-credentials/state-licensure',
      steps: [
        'Confirm whether your target state is one of the ~13 that mandate licensure (e.g. California, New York, Florida)',
        'Apply for ASCP (or another acceptable agency\'s) certification, since most states require it regardless of licensure',
        'If your state requires licensure, apply directly to that state\'s medical laboratory personnel licensing board',
        'Note California is the exception — it doesn\'t recognise ASCP or any out-of-state licence, and runs its own process',
      ],
    ),
    'United Arab Emirates': LedgerEntry(
      'DHA / DOH / MOHAP',
      note: 'allied health — lab technologist',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://services.dha.gov.ae/',
      steps: [
        'Create an account on the DHA Sheryan portal (or the DOH/MOHAP equivalent for your emirate)',
        'Submit documents for DataFlow primary-source verification',
        'Apply for your Eligibility Certificate once DataFlow is approved',
        'Sit the Prometric licensing exam for lab technologists if required',
        'Secure a job offer — your hiring facility activates your licence in Sheryan',
      ],
    ),
  },
);

const _pharmacistRow = OccupationLedgerRow(
  occupation: 'Pharmacist',
  byCountry: {
    'Canada': LedgerEntry(
      'Provincial college',
      note: 'PEBC exam, NAPRA-coordinated',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://pebc.ca/pharmacists/certification-pathway/international-graduates/',
      steps: [
        'Enrol in Pharmacists\' Gateway Canada and receive a national ID number',
        'Register with PEBC and pass the Document Evaluation of your credentials (up to 8 weeks)',
        'Sit and pass the PEBC Evaluating Examination, unless you qualify for the streamlined pathway',
        'Sit and pass the Pharmacist Qualifying Examination Part I (MCQ) and Part II (OSCE)',
        'Apply to your provincial college (e.g. Ontario College of Pharmacists) for registration',
      ],
    ),
    'Australia': LedgerEntry(
      'Pharmacy Board of Australia',
      note: 'under AHPRA',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.pharmacyboard.gov.au/Registration/Overseas.aspx',
      steps: [
        'Apply to the Australian Pharmacy Council (APC) for an eligibility assessment of your qualifications',
        'Once approved, sit and pass the KAPS (or OPRA) exam',
        'Meet the English language requirement',
        'Apply online for provisional registration with AHPRA (Pharmacy Board of Australia)',
        'Complete a supervised internship, then pass the registration examination (written + oral) within 18 months',
      ],
    ),
    'New Zealand': LedgerEntry(
      'Pharmacy Council of NZ',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://pharmacycouncil.org.nz/pharmacy_registries/pharmacists-from-other-countries/',
      steps: [
        'Apply for a Preliminary Review of your qualifications, registration, and overseas experience',
        'Receive an Eligibility Letter and book the OPRA (Overseas Pharmacist Readiness Assessment)',
        'Pass the OPRA, then complete the NZ pharmacist legislation course',
        'Obtain an Annual Practising Certificate before starting your internship',
        'Complete a minimum 1,450 hours of supervised practice',
      ],
    ),
    'Germany': LedgerEntry(
      'Approbation',
      note: 'via state Apothekerkammer',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.anerkennung-in-deutschland.de/',
      steps: [
        'Contact the Approbationsbehörde for the state where you plan to work',
        'Submit your qualification documents for an equivalency assessment',
        'Reach C1-level specialist German',
        'Complete a compensatory measure (adaptation period or knowledge exam) if not automatically equivalent',
        'Receive your Approbation to practise as a pharmacist',
      ],
    ),
    'United Kingdom': LedgerEntry(
      'GPhC',
      note: 'General Pharmaceutical Council',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.pharmacyregulation.org/pharmacists/registering-pharmacist',
      steps: [
        'Confirm your qualification and registration route with the GPhC',
        'Meet the GPhC\'s English language requirement',
        'Submit your application and supporting documents for assessment',
        'Sit and pass any required competence exam',
        'Register with the GPhC to practise in Great Britain',
      ],
    ),
    'Netherlands': LedgerEntry(
      'BIG-register',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://english.bigregister.nl/',
      steps: [
        'Use the Advice Wizard to identify which recognition procedure applies to your diploma',
        'Submit your application for recognition of your foreign pharmacy diploma',
        'Reach the required Dutch language level',
        'Wait for the recognition decision — up to 12 weeks',
        'Once recognised, apply for mandatory BIG registration',
      ],
    ),
    'Ireland': LedgerEntry(
      'PSI',
      note: 'Pharmaceutical Society of Ireland',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.psi.ie/registration',
      steps: [
        'Determine your registration route based on where you trained (EU/EEA vs. third country)',
        'If third-country trained, apply to have your qualification recognised by the PSI',
        'Complete the PSI\'s qualification recognition assessment',
        'Submit your application to be added to the register of pharmacists',
      ],
    ),
    'Singapore': LedgerEntry(
      'Singapore Pharmacy Council',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.spc.gov.sg/for-professionals/apply-for-registration/foreign-trained-pharmacy-graduates-pharmacists/',
      steps: [
        'Secure a job offer with an SPC-approved training institution first — SPC won\'t consider an application without one',
        'Submit your registration application online via the Professional Registration System (PRS)',
        'Complete prescribed pre-registration training and accrue at least 3 months of practical experience',
        'Pass the Competency and Forensic examinations prescribed by SPC',
        'Receive Conditional Registration and a practising certificate',
      ],
    ),
    'United States': LedgerEntry(
      'State Board of Pharmacy',
      note: 'NABP / FPGEC',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://nabp.pharmacy/programs/foreign-pharmacy/',
      steps: [
        'Create an NABP e-Profile and apply for FPGEC Certification',
        'Submit your foreign licence/registration and a qualifying TOEFL iBT score',
        'Await document evaluation — up to 8 weeks once all documentation is received',
        'Sit and pass the FPGEE (score of 75+) within 2 years of acceptance',
        'Contact your chosen State Board of Pharmacy for that state\'s remaining licensure requirements',
      ],
    ),
    'United Arab Emirates': LedgerEntry(
      'DHA / DOH / MOHAP',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://services.dha.gov.ae/',
      steps: [
        'Create an account on the DHA Sheryan portal (or the DOH/MOHAP equivalent for your emirate)',
        'Submit documents for DataFlow primary-source verification',
        'Apply for your Eligibility Certificate once DataFlow is approved',
        'Sit and pass the DHA Prometric exam for pharmacists',
        'Secure a job offer — your hiring facility activates your licence in Sheryan',
      ],
    ),
  },
);

/// Shared by every HCPC-regulated allied health profession in this file
/// (physio, OT, and — later — paramedic/psychologist rows), since the
/// International Application Route process itself doesn't vary by profession.
const _hcpcInternationalSteps = [
  'Confirm you\'re eligible to apply via the International Application Route for your specific profession',
  'Meet the English language requirement (e.g. IELTS 7.0 overall, no element below 6.5)',
  'Complete the online HCPC application, evidencing the Standards of Proficiency for your profession',
  'Certify and translate all documents into English, then pay the one-off Scrutiny Fee',
  'Await assessment by two Registration Assessors — HCPC aims to respond within 60 working days',
];
const _hcpcUrl = 'https://www.hcpc-uk.org/registration/getting-on-the-register/international-applications/';

/// Shared by every AHPC-registered allied health profession (Singapore) —
/// the registration process itself is profession-blind.
const _ahpcSingaporeSteps = [
  'Secure an offer of employment as an Allied Health Professional in Singapore first',
  'Complete the Pre-application form, then log in to the Professional Registration System (PRS) to submit your application',
  'Provide evidence of your qualification and good standing/character',
  'Once approved, pay for your Practising Certificate',
  'Download your registration and Practising Certificate from the PRS',
];
const _ahpcUrl = 'https://www.ahpc.gov.sg/for-professionals/apply-for-registration/';

/// The generic Anerkennung (recognition) process shared by every regulated
/// German profession in this file that doesn't have its own distinct
/// examination pathway already described elsewhere (Approbation professions
/// like doctor/pharmacist/psychotherapist have their own more specific steps).
const _germanAnerkennungSteps = [
  'Use the Recognition Finder tool at anerkennung-in-deutschland.de to identify your state\'s competent authority',
  'Submit your qualification documents for an equivalency assessment',
  'Reach the German language level required for your profession (typically B2 general, sometimes C1 specialist)',
  'Complete a compensatory measure (adaptation period or knowledge exam) if not automatically equivalent',
  'Receive written confirmation of recognition and permission to use the professional title',
];
const _germanAnerkennungUrl = 'https://www.anerkennung-in-deutschland.de/';

/// Shared by every CORU-regulated profession (Ireland) — recognition, then
/// registration, is the same two-step process regardless of profession.
const _coruRecognitionSteps = [
  'Apply to CORU for recognition of your international qualification via the online recognition system',
  'Have your qualification assessed against the Standards of Proficiency for your profession',
  'Address any identified gaps via further learning, experience, or compensation measures',
  'Once recognition is confirmed, begin your registration application',
];
const _coruUrl = 'https://www.coru.ie/health-and-social-care-professionals/registration/international-applicants/how-to-apply/';

/// Shared by every DHA/DOH/MOHAP allied-health profession (UAE) — same
/// Sheryan/DataFlow/Prometric pipeline regardless of profession.
const _dhaAlliedHealthSteps = [
  'Create an account on the DHA Sheryan portal (or the DOH/MOHAP equivalent for your emirate)',
  'Submit documents for DataFlow primary-source verification',
  'Apply for your Eligibility Certificate once DataFlow is approved',
  'Sit the DHA Prometric exam for your profession if required',
  'Secure a job offer — your hiring facility activates your licence in Sheryan',
];
const _dhaUrl = 'https://services.dha.gov.ae/';

/// Shared BIG-register recognition process (Netherlands) — profession-blind
/// once you know which of the 3 procedures applies to your diploma.
const _bigRegisterSteps = [
  'Use the Advice Wizard to identify which recognition procedure applies to your diploma',
  'Submit your application for recognition of your foreign diploma',
  'Reach the required Dutch language level',
  'Wait for the recognition decision — up to 12 weeks',
  'Once recognised, apply for mandatory BIG registration',
];
const _bigUrl = 'https://english.bigregister.nl/';

const _physiotherapistRow = OccupationLedgerRow(
  occupation: 'Physiotherapist',
  byCountry: {
    'Canada': LedgerEntry(
      'Provincial college',
      note: 'e.g. College of Physiotherapists of Ontario',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://collegept.org/how-to-become-a-physiotherapist',
      steps: [
        'Connect with the Canadian Alliance of Physiotherapy Regulators (CAPR) for credentialling',
        'Complete CAPR\'s education/qualification credentialling and a language assessment',
        'Sit and pass the Canadian Physiotherapy Competency Exam (up to 3 attempts)',
        'Apply for an Independent Practice Certificate of Registration with your provincial college (e.g. College of Physiotherapists of Ontario)',
      ],
    ),
    'Australia': LedgerEntry(
      'Physiotherapy Board',
      note: 'under AHPRA',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.physiotherapyboard.gov.au/registration/overseas-practitioners.aspx',
      steps: [
        'Read the Board\'s information for international practitioners before applying',
        'Complete an assessment with the Australian Physiotherapy Council if your qualification is international',
        'Submit certified copies of your qualifications via the AHPRA practitioner portal',
        'Complete an international criminal history check if you\'ve lived overseas 6+ months as an adult',
        'Meet the Board\'s English language skills registration standard',
      ],
    ),
    'New Zealand': LedgerEntry(
      'Physiotherapy Board',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://physioboard.org.nz/i-want-to-be-registered',
      steps: [
        'Check if you qualify for the International Express Pathway (UK, Ireland, Canada, South Africa) or Trans-Tasman Mutual Recognition (Australia) — otherwise use the International General Pathway',
        'Have your qualification assessed against the Physiotherapy practice thresholds for Australia and NZ',
        'Submit Certificates of Good Standing, police certificates, a CV on the Board template, and 2 cultural competency course certificates',
        'If your curriculum doesn\'t meet the threshold outright, submit supporting evidence within 3 months (Phase 3)',
        'Once registered, apply for an Annual Practising Certificate before you can practise',
      ],
    ),
    'Germany': LedgerEntry('Anerkennung', note: 'protected title, regional authority', confidence: LedgerConfidence.verified, officialUrl: _germanAnerkennungUrl, steps: _germanAnerkennungSteps),
    'United Kingdom': LedgerEntry('HCPC', confidence: LedgerConfidence.verified, officialUrl: _hcpcUrl, steps: _hcpcInternationalSteps),
    'Netherlands': LedgerEntry('BIG-register', confidence: LedgerConfidence.verified, officialUrl: _bigUrl, steps: _bigRegisterSteps),
    'Ireland': LedgerEntry('CORU', confidence: LedgerConfidence.verified, officialUrl: _coruUrl, steps: _coruRecognitionSteps),
    'Singapore': LedgerEntry('AHPC', note: 'Allied Health Professions Council', confidence: LedgerConfidence.verified, officialUrl: _ahpcUrl, steps: _ahpcSingaporeSteps),
    'United States': LedgerEntry(
      'State licensing board',
      note: 'FSBPT / NPTE',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.fsbpt.org/Free-Resources/Foreign-Educated-PTs-and-PT-Assistants',
      steps: [
        'Have your education evaluated by the FCCPT for equivalence to a US PT degree',
        'Complete any coursework needed to address educational deficiencies',
        'Submit your credential evaluation to your target state board along with that state\'s other requirements',
        'Receive authorization to test from FSBPT and register for the NPTE',
        'Pass the NPTE — required for licensure in every state',
      ],
    ),
    'United Arab Emirates': LedgerEntry('DHA / DOH / MOHAP', confidence: LedgerConfidence.verified, officialUrl: _dhaUrl, steps: _dhaAlliedHealthSteps),
  },
);

const _occupationalTherapistRow = OccupationLedgerRow(
  occupation: 'Occupational Therapist',
  byCountry: {
    'Canada': LedgerEntry('Provincial college', confidence: LedgerConfidence.directional),
    'Australia': LedgerEntry(
      'Occupational Therapy Board',
      note: 'under AHPRA',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.occupationaltherapyboard.gov.au/Registration/Internationally-qualified-occupational-therapists.aspx',
      steps: [
        'Have your qualification assessed by AHPRA against the Board\'s criteria (substantially equivalent, similar competencies, or relevant)',
        'If only "relevant," complete a Practical Assessment of Competence before applying for general registration',
        'Complete the Indigenous Allied Health Australia cultural responsiveness training programme',
        'Apply for registration via the AHPRA portal with certified documents and an English test result',
      ],
    ),
    'New Zealand': LedgerEntry(
      'Occupational Therapy Board',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.otboard.org.nz/site/rp/overseas?nav=sidebar',
      steps: [
        'Check if you qualify for the Abridged Pathway (UK, Ireland, Canada, South Africa) — otherwise use the Standard overseas pathway',
        'Provide 3 references, including one OT colleague of 6+ months in the last 2 years',
        'Supply a certificate of good standing and disclose any disciplinary history',
        'Complete a criminal history check for every country lived in 6+ months over the last 10 years',
        'Complete the Ngā Paerewa Te Tiriti eLearning course and written competency assessment',
        'Register and apply for a practising certificate before starting work',
      ],
    ),
    'Germany': LedgerEntry('Anerkennung', confidence: LedgerConfidence.verified, officialUrl: _germanAnerkennungUrl, steps: _germanAnerkennungSteps),
    'United Kingdom': LedgerEntry('HCPC', confidence: LedgerConfidence.verified, officialUrl: _hcpcUrl, steps: _hcpcInternationalSteps),
    'Netherlands': LedgerEntry('Not in core BIG list', note: 'likely a voluntary quality register — verify directly', confidence: LedgerConfidence.directional, applicable: false),
    'Ireland': LedgerEntry('CORU', confidence: LedgerConfidence.verified, officialUrl: _coruUrl, steps: _coruRecognitionSteps),
    'Singapore': LedgerEntry('AHPC', confidence: LedgerConfidence.verified, officialUrl: _ahpcUrl, steps: _ahpcSingaporeSteps),
    'United States': LedgerEntry(
      'State licensing board',
      note: 'NBCOT',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.nbcot.org/get-certified/eligibility',
      steps: [
        'If not ACOTE-accredited, apply for NBCOT\'s Occupational Therapist Eligibility Determination (OTED) with certified translated transcripts',
        'Confirm your education included at least 960 hours of fieldwork',
        'Complete any additional education OTED identifies as needed (approval is valid 7 years)',
        'Sit and pass the NBCOT exam',
        'Apply for licensure with your target state\'s licensing board',
      ],
    ),
    'United Arab Emirates': LedgerEntry('DHA / DOH / MOHAP', confidence: LedgerConfidence.verified, officialUrl: _dhaUrl, steps: _dhaAlliedHealthSteps),
  },
);

const _midwifeRow = OccupationLedgerRow(
  occupation: 'Midwife',
  byCountry: {
    'Canada': LedgerEntry(
      'Provincial college of midwives',
      note: 'separate from nursing college',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://cmo.on.ca/iem/',
      steps: [
        'Apply to your provincial college\'s Orientation and Assessment Program for internationally educated midwives (e.g. College of Midwives of Ontario)',
        'Complete the online assessment modules and an in-person comprehensive assessment intensive',
        'Sit and pass the Canadian Midwifery Registration Exam (CMRE)',
        'Apply for registration with your provincial college once deemed equivalent to a local graduate',
      ],
    ),
    'Australia': LedgerEntry(
      'Nursing & Midwifery Board',
      note: 'under AHPRA, separate register',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://anmac.org.au/skilled-migrants/assessment-process',
      steps: [
        'Complete an ANMAC skills assessment for midwifery (a migration document, not itself a clinical registration)',
        'Meet the English test requirement (IELTS, OET, PTE Academic, or TOEFL iBT)',
        'Apply for AHPRA registration via the Internationally Qualified Midwife pathway',
        'Submit certified documents and complete any bridging/outcome-based assessment if required',
      ],
    ),
    'New Zealand': LedgerEntry(
      'Midwifery Council of NZ',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.midwiferycouncil.health.nz/Web/Web/I-want-to-become-a-midwife-in-New-Zealand/Overseas-Registered-Midwife.aspx',
      steps: [
        'Confirm your registration authority performs a similar function to the Council — the Council only considers a limited list of comparable countries',
        'Complete the Comparability IQM Tool and a self-assessment against the Standards of Competence',
        'Meet the English requirement — IELTS Academic 7.0 overall, 7.0 in every band',
        'Provide police reports from your country of residence and every country lived in 12+ months since age 18, sent directly to the Council',
        'Submit certified ID and evidence of your post-registration midwifery experience',
      ],
    ),
    'Germany': LedgerEntry('State authority', note: 'Hebammengesetz', confidence: LedgerConfidence.directional),
    'United Kingdom': LedgerEntry('NMC', note: 'joint register with nurses', confidence: LedgerConfidence.verified, officialUrl: 'https://www.nmc.org.uk/registration/joining-the-register/', steps: [
      'Confirm you hold an unrestricted midwifery licence in your country of qualification',
      'Meet the English requirement (e.g. IELTS Academic 7.0 overall, 6.5 writing, or equivalent OET)',
      'Submit your application and documents, and pay the evaluation fee',
      'Sit and pass the Test of Competence for midwives (CBT + OSCE)',
      'Submit your final registration application and fee to receive your NMC PIN',
    ]),
    'Netherlands': LedgerEntry('BIG-register', note: 'distinct entry', confidence: LedgerConfidence.verified, officialUrl: _bigUrl, steps: _bigRegisterSteps),
    'Ireland': LedgerEntry('NMBI', confidence: LedgerConfidence.verified),
    'Singapore': LedgerEntry('Singapore Nursing Board', confidence: LedgerConfidence.directional),
    'United States': LedgerEntry(
      'Varies by state',
      note: 'state board + AMCB certification (CNM)',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.amcbmidwife.org/amcb-certification/application-process',
      steps: [
        'Have your foreign credentials evaluated by a recognised credential evaluation service',
        'Complete at least one additional course from an ACME-accredited midwifery program — most foreign-educated midwives need this',
        'Hold a US Registered Nurse licence if pursuing the CNM (Certified Nurse-Midwife) pathway',
        'Submit your AMCB exam application and await eligibility confirmation',
        'Pass the AMCB national certification exam, then apply to your target state\'s licensing agency',
      ],
    ),
    'United Arab Emirates': LedgerEntry('DHA / DOH / MOHAP', confidence: LedgerConfidence.verified, officialUrl: _dhaUrl, steps: _dhaAlliedHealthSteps),
  },
);

const _paramedicHealthcareRow = OccupationLedgerRow(
  occupation: 'Paramedic',
  byCountry: {
    'Canada': LedgerEntry(
      'Provincial regulator',
      note: 'self- or govt-regulated by province; COPR for intl. applicants',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://copr.ca/assessment-of-international-applicants/',
      steps: [
        'Create a COPR (Canadian Organization of Paramedic Regulators) account via the Applicant Portal',
        'Complete COPR\'s competency self-assessment tool',
        'Submit your eligibility assessment application and required documents, with translations if needed',
        'Sit COPR\'s required examinations',
        'Apply to the paramedic regulator in the province where you intend to practise',
      ],
    ),
    'Australia': LedgerEntry(
      'Paramedicine Board',
      note: 'under AHPRA since 2018',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.paramedicineboard.gov.au/Qualifications/Assessment-of-overseas-qualifications.aspx',
      steps: [
        'Apply for an Overseas Qualifications Assessment with the required fee and documents',
        'If only "relevant" (not substantially equivalent), complete the Board\'s competency assessment',
        'Arrange an international criminal history check and professional indemnity insurance',
        'Submit your registration application with identification, qualifications, and English test evidence',
      ],
    ),
    'New Zealand': LedgerEntry(
      'Paramedic Council',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://paramediccouncil.org.nz/PCNZ/PCNZ/2.Paramedics/Overseas-qualified-paramedics-.aspx',
      steps: [
        'Prepare documentation matching your qualification\'s learning objectives against Te Kaunihera\'s competence standards',
        'Provide evidence you can communicate in English to an acceptable standard',
        'Submit your registration application online with all required documents',
        'Await the Council\'s assessment of equivalence and fitness for registration under the HPCA Act',
      ],
    ),
    'Germany': LedgerEntry('Notfallsanitäter exam', note: 'state exam, no separate registration board', confidence: LedgerConfidence.verified),
    'United Kingdom': LedgerEntry('HCPC', confidence: LedgerConfidence.verified, officialUrl: _hcpcUrl, steps: _hcpcInternationalSteps),
    'Netherlands': LedgerEntry(
      'BIG-register',
      note: 'ambulance nurse is a nursing specialization, not a separate paramedic profession',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://english.bigregister.nl/registration/procedures/specialization',
      steps: [
        'Register as a nurse in the BIG-register first (see the Registered Nurse row)',
        'Apply for the ambulanceverpleegkundige (ambulance nurse) specialist registration via the RSV (Registratiecommissie Specialismen Verpleegkunde)',
        'Complete the specific reserved-actions training this specialization requires',
      ],
    ),
    'Ireland': LedgerEntry(
      'PHECC, not CORU',
      note: 'Pre-Hospital Emergency Care Council',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://phecc.ie/register/joining-the-register/',
      steps: [
        'Hold the National Qualification in Emergency Medical Technology (NQEMT) at the appropriate level, as awarded by PHECC',
        'Complete the hardcopy application form with an ID-quality passport photo',
        'Pay the Annual Registration Fee via the PHECC Online Store',
        'Email the signed form and receipt to registration@phecc.ie',
      ],
    ),
    'Singapore': LedgerEntry(
      'Not a personal registration',
      note: 'SCDF training pathway, overseen by an external medical advisory committee under the Ministry of Home Affairs',
      confidence: LedgerConfidence.verified,
      applicable: false,
      officialUrl: 'https://www.moh.gov.sg/newsroom/paramedic-regulation-and-training/',
      steps: [
        'Complete the full-time one-year Paramedicine diploma at Nanyang Polytechnic (for the SCDF Paramedic Officer route)',
        'Complete 3 months of training with SCDF\'s Emergency Medical Service',
        'Hold BCLS, ACLS, and PHTLS certifications',
        'Practise under the oversight of the independent external medical advisory committee (MOH/MHA), rather than joining a professional register',
      ],
    ),
    'United States': LedgerEntry(
      'State EMS board',
      note: 'NREMT cert feeds state licensure',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.nremt.org/Paramedic/Certification',
      steps: [
        'Complete a US-based, CAAHEP-accredited Paramedic education program — foreign paramedic training alone isn\'t accepted',
        'Confirm which of your prior credits/experience your program will accept as transfer or advanced placement',
        'Sit the National Registry exam at a Pearson VUE or Pearson Professional Center',
        'Complete any state-specific jurisprudence examination',
        'Apply to your target state\'s EMS office for licensure — NREMT certification alone isn\'t a licence to practise',
      ],
    ),
    'United Arab Emirates': LedgerEntry('DHA / DOH / MOHAP', confidence: LedgerConfidence.directional),
  },
);

const _clinicalPsychologistRow = OccupationLedgerRow(
  occupation: 'Clinical Psychologist',
  byCountry: {
    'Canada': LedgerEntry(
      'Provincial College of Psychologists',
      note: 'e.g. Ordre des psychologues du Québec',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://cpbao.ca/cpo_resources/psychologist-registration-flowchart-international/',
      steps: [
        'Submit your application for Supervised Practice registration and fee to your provincial college (e.g. CPBAO in Ontario)',
        'Have your academic credentials assessed by a recognised evaluator (e.g. WES or CES), sent directly to the college',
        'Have your university send transcripts directly to the college',
        'Provide evidence of English or French language fluency',
        'Complete supervised practice, then apply for full registration',
      ],
    ),
    'Australia': LedgerEntry(
      'Psychology Board',
      note: 'under AHPRA',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.psychologyboard.gov.au/Registration/Overseas-Applicants/Applying-for-registration.aspx',
      steps: [
        'Apply for provisional registration first — all overseas-qualified psychologists must, before general registration',
        'Have your institution send original academic transcripts directly to AHPRA',
        'Obtain a Certificate of Registration Status or Good Standing from every jurisdiction you\'ve been registered in over the past 5 years',
        'Meet AHPRA\'s English language skills registration standard',
        'Submit your application via the AHPRA portal with certified documents and fees',
      ],
    ),
    'New Zealand': LedgerEntry(
      'NZ Psychologists Board',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://psychologistsboard.org.nz/want-to-register/overseas-trained-how-to-register/',
      steps: [
        'Check if you trained/practise in a "prescribed country" (Australia, Canada, UK, US, South Africa) for a more direct process',
        'Evidence a 6-year psychology course of study, 1,500 supervised practice hours, and an internship/licensing endpoint evaluation',
        'Provide references, including one from a senior registered/chartered psychologist',
        'Submit your application for assessment of fitness, qualification equivalence, and competence — 4–6 months processing',
        'Complete the Raka Māui Competence Programme within 2 years of registration if it applies to you',
      ],
    ),
    'Germany': LedgerEntry(
      'Approbation',
      note: 'as Psychological Psychotherapist, for clinical practice',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.anerkennung-in-deutschland.de/html/en/2724.php',
      steps: [
        'Submit your application for an Approbation to practise as a psychotherapist to the competent authority',
        'Have your foreign qualification compared against the German qualification for equivalence',
        'Reach B2 general German and C1 specialist/clinical German',
        'If not equivalent, complete a compensatory measure: an aptitude test (oral + practical) or an adaptation period',
        'Receive your Approbation',
      ],
    ),
    'United Kingdom': LedgerEntry('HCPC', note: 'Practitioner / Clinical Psychologist', confidence: LedgerConfidence.verified, officialUrl: _hcpcUrl, steps: _hcpcInternationalSteps),
    'Netherlands': LedgerEntry('BIG-register', note: 'as health psychologist', confidence: LedgerConfidence.verified, officialUrl: _bigUrl, steps: _bigRegisterSteps),
    'Ireland': LedgerEntry('Not yet regulated', note: 'CORU registration pending; currently voluntary via PSI', confidence: LedgerConfidence.verified, applicable: false),
    'Singapore': LedgerEntry('Not government-regulated', note: 'voluntary Singapore Register of Psychologists', confidence: LedgerConfidence.verified, applicable: false),
    'United States': LedgerEntry(
      'State licensing board',
      note: 'EPPP exam via ASPPB',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://asppb.net/licensure/internationally-trained-applicants/',
      steps: [
        'Review the licensing requirements of your target state/jurisdiction and contact its licensing authority directly',
        'Have a NACES-member credential evaluation service translate your degree into a US/Canada-comparable format',
        'Demonstrate your supervised experience is equivalent to what your jurisdiction requires',
        'Apply to become a candidate for licensure once equivalence is demonstrated',
        'Pass the EPPP, plus any state-specific exam on local mental health law',
      ],
    ),
    'United Arab Emirates': LedgerEntry('DHA / DOH / MOHAP', confidence: LedgerConfidence.directional),
  },
);

const _socialWorkerRow = OccupationLedgerRow(
  occupation: 'Social Worker',
  byCountry: {
    'Canada': LedgerEntry(
      'Provincial college/assoc.',
      note: 'mandatory in most provinces; not in Yukon/Nunavut',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.ocswssw.org/applicants/international-bsw-msw/',
      steps: [
        'Apply to CASW (Canadian Association of Social Workers) to have your international degree evaluated for equivalency',
        'Have your official documents translated into English or French',
        'Submit a valid Canadian work or study permit with your application',
        'Apply to your provincial college (e.g. OCSWSSW in Ontario) under the "Social Worker Graduate" category',
        'Start the process at least 4–6 weeks before you intend to begin practising',
      ],
    ),
    'Australia': LedgerEntry(
      'Not statutorily regulated',
      note: 'voluntary AASW accreditation',
      confidence: LedgerConfidence.verified,
      applicable: false,
      officialUrl: 'https://www.aasw.asn.au/education-employment/international-qualification-recognition/',
      steps: [
        'Confirm your qualification is a recognised professional social work qualification in your country of origin',
        'Submit an academic transcript and a completed Course Information Form (or professional statement) to the AASW',
        'Await the AASW\'s comparative assessment of your learning outcomes against an accredited Australian qualification — 12–16 weeks',
        'Join the AASW voluntarily once assessed, since there is no statutory register to join instead',
      ],
    ),
    'New Zealand': LedgerEntry(
      'Social Workers Registration Board',
      note: 'mandatory since 2019 Act',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://swrb.govt.nz/registration/overseas-qualified-social-workers/',
      steps: [
        'Confirm your qualification is equivalent to an SWRB-prescribed social work qualification',
        'Confirm you\'re registered/licensed as a social worker elsewhere (or have good reason not to be)',
        'Create a MySWRB account and select the Overseas Qualification pathway',
        'Complete the overseas qualification assessment form, listing your roles and professional development',
        'Submit academic transcripts and evidence of your overseas registration',
      ],
    ),
    'Germany': LedgerEntry('Not centrally licensed', note: 'state-recognized academic title only', confidence: LedgerConfidence.directional),
    'United Kingdom': LedgerEntry(
      'Social Work England',
      note: 'England-specific; other UK nations differ',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.socialworkengland.org.uk/registration/overseas-applicant-guidance/',
      steps: [
        'Create an online account with Social Work England',
        'Demonstrate English knowledge — IELTS, a recent qualification from an English-speaking country, or proven practice history in English',
        'Submit certified colour copies of ID and proof of address',
        'Have your overseas qualification assessed by a registration adviser',
        'Agree to and pay the registration fees, then submit your application',
      ],
    ),
    'Netherlands': LedgerEntry('Not regulated', note: 'outside child/youth care & mental health contexts', confidence: LedgerConfidence.verified, applicable: false),
    'Ireland': LedgerEntry('CORU', confidence: LedgerConfidence.verified, officialUrl: _coruUrl, steps: _coruRecognitionSteps),
    'Singapore': LedgerEntry('Voluntary only', note: 'Singapore Assoc. of Social Workers (SASW)', confidence: LedgerConfidence.directional, applicable: false),
    'United States': LedgerEntry(
      'State licensing board',
      note: 'ASWB exam — LMSW/LCSW tiers',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.aswb.org/licenses/how-to-get-a-license/',
      steps: [
        'Confirm which licence category your target state offers (e.g. LMSW for a Master\'s degree, LCSW for clinical practice)',
        'Have your international social work degree evaluated for US equivalency',
        'Complete any state-required supervised clinical hours for the LCSW tier',
        'Register for and pass the relevant ASWB exam (Bachelors, Masters, Clinical, or Advanced Generalist)',
        'Apply to your target state\'s licensing board for your social work licence',
      ],
    ),
    'United Arab Emirates': LedgerEntry('Not standard-licensed', note: 'employer / CDA context-based', confidence: LedgerConfidence.directional, applicable: false),
  },
);

LedgerEntry _careWorkerEntry(String country) {
  const entries = {
    'Canada': LedgerEntry('Not licensed', note: 'PSW vocational certificate, not govt-licensed', confidence: LedgerConfidence.notRegulated, applicable: false),
    'Australia': LedgerEntry('Not licensed', note: 'worker screening check + Cert III/IV Individual Support', confidence: LedgerConfidence.notRegulated, applicable: false),
    'New Zealand': LedgerEntry('Not licensed', note: 'NZ Cert. in Health & Wellbeing (vocational)', confidence: LedgerConfidence.notRegulated, applicable: false),
    'Germany': LedgerEntry(
      'Altenpfleger/in Anerkennung',
      note: 'state-recognized vocational qualification — closer to a trade recognition',
      confidence: LedgerConfidence.verified,
      officialUrl: _germanAnerkennungUrl,
      steps: _germanAnerkennungSteps,
    ),
    'United Kingdom': LedgerEntry('Not licensed', note: 'Care Certificate (vocational) + enhanced DBS', confidence: LedgerConfidence.notRegulated, applicable: false),
    'Netherlands': LedgerEntry('Not licensed', note: 'MBO Verzorgende diploma, SBB recognition', confidence: LedgerConfidence.notRegulated, applicable: false),
    'Ireland': LedgerEntry('Not licensed', note: 'HSE/QQI vocational qualification + Garda vetting', confidence: LedgerConfidence.notRegulated, applicable: false),
    'Singapore': LedgerEntry('Not licensed', note: 'WSQ vocational certificate, employer-driven', confidence: LedgerConfidence.notRegulated, applicable: false),
    'United States': LedgerEntry('Not licensed', note: 'state CNA registry in most states — lower bar than clinical licensure', confidence: LedgerConfidence.verified, applicable: false),
    'United Arab Emirates': LedgerEntry('Not licensed', note: 'employer / visa classification only', confidence: LedgerConfidence.notRegulated, applicable: false),
  };
  return entries[country]!;
}

OccupationLedgerRow _careWorkerRow(String occupation) => OccupationLedgerRow(
      occupation: occupation,
      byCountry: {for (final c in _countries) c: _careWorkerEntry(c)},
    );

const _clinicalTrialManagerRow = OccupationLedgerRow(
  occupation: 'Clinical Trial Manager',
  byCountry: {
    'Canada': LedgerEntry('Not regulated', note: 'GCP training governs practice, not a licence', confidence: LedgerConfidence.notRegulated, applicable: false),
    'Australia': LedgerEntry('Not regulated', confidence: LedgerConfidence.notRegulated, applicable: false),
    'New Zealand': LedgerEntry('Not regulated', confidence: LedgerConfidence.notRegulated, applicable: false),
    'Germany': LedgerEntry('Not regulated', confidence: LedgerConfidence.notRegulated, applicable: false),
    'United Kingdom': LedgerEntry('Not regulated', confidence: LedgerConfidence.notRegulated, applicable: false),
    'Netherlands': LedgerEntry('Not regulated', confidence: LedgerConfidence.notRegulated, applicable: false),
    'Ireland': LedgerEntry('Not regulated', confidence: LedgerConfidence.notRegulated, applicable: false),
    'Singapore': LedgerEntry('Not regulated', confidence: LedgerConfidence.notRegulated, applicable: false),
    'United States': LedgerEntry('Not regulated', note: 'CCRA (ACRP) / CCRP (SOCRA) are certifications, not licences', confidence: LedgerConfidence.notRegulated, applicable: false),
    'United Arab Emirates': LedgerEntry('Not regulated', confidence: LedgerConfidence.notRegulated, applicable: false),
  },
);

const _countries = [
  'Canada', 'Australia', 'New Zealand', 'Germany', 'United Kingdom',
  'Netherlands', 'Ireland', 'Singapore', 'United States', 'United Arab Emirates',
];

// ---------------------------------------------------------------------
// Engineering
// ---------------------------------------------------------------------

const _caEngGeneric = LedgerEntry(
  'Provincial regulator',
  note: 'e.g. PEO, EGBC',
  confidence: LedgerConfidence.verified,
  officialUrl: 'https://www.peo.on.ca/licence-applications/international-engineering-graduates',
  steps: [
    'Have your international degree assessed — request a course-by-course report from World Education Services (WES) if it\'s not CEAB-accredited',
    'Get non-English academic documents translated by an ATIO-certified translator or a Canadian P.Eng.',
    'Accrue the required engineering experience (2 years minimum as of July 2026) and pass the competency-based assessment',
    'Pass the good character assessment',
    'Submit your complete application to your provincial regulator (e.g. PEO) within 6 months of landing in Canada',
  ],
);
const _nzEngGeneric = LedgerEntry(
  'Engineering NZ (CPEng)',
  note: 'voluntary',
  confidence: LedgerConfidence.verified,
  mandatory: false,
  officialUrl: 'https://www.registrationauthority.org.nz/get-chartered',
  steps: [
    'Confirm eligibility — a Washington Accord-accredited qualification, or demonstrated equivalent knowledge',
    'Gain 4–6 years of experience on complex engineering work before applying',
    'Apply online with your CV, annotated work samples, and a signed self-assessment form',
    'Submit a draft application for a Competence Assessment Advisor to review and give feedback',
    'Have an assessment panel review your formal application over 8–10 weeks, including a possible meeting',
    'Once chartered, be reassessed at least every 6 years',
  ],
);
const _deEngGeneric = LedgerEntry(
  'Ingenieurkammer',
  note: 'voluntary, title only',
  confidence: LedgerConfidence.verified,
  mandatory: false,
  officialUrl: 'https://www.anerkennung-in-deutschland.de/html/en/2722.php',
  steps: [
    'Submit an application for authorization to use the "Ingenieur" title to the competent state authority',
    'Have your qualification compared against the German equivalent (equivalence determination)',
    'Provide German translations of your documents from a publicly appointed translator',
    'Reach B2-level German',
    'If not automatically equivalent, complete a compensatory measure (adaptation course or aptitude test)',
  ],
);
const _nlEngGeneric = LedgerEntry('Not regulated', confidence: LedgerConfidence.verified, applicable: false);
const _ieEngGeneric = LedgerEntry(
  'Engineers Ireland',
  note: 'voluntary',
  confidence: LedgerConfidence.verified,
  mandatory: false,
  officialUrl: 'https://www.engineersireland.ie/Professionals/Membership/Registered-professional-titles/Chartered-Engineer',
  steps: [
    'Confirm your qualification: Washington Accord-accredited, an EU-equivalent degree, or a listed Second Cycle Degree',
    'Submit your application documentation for assessment ahead of the January or June deadline',
    'Secure supporters — Chartered Engineers with Engineers Ireland familiar with your formation as an engineer',
    'Attend an interview with two or three experienced Chartered Engineers',
    'Receive your Chartered Engineer title, recognised internationally via Engineers Ireland\'s mutual agreements',
  ],
);
const _usEngGeneric = LedgerEntry(
  'State PE board',
  note: 'industrial exemption covers most employed engineers',
  confidence: LedgerConfidence.verified,
  mandatory: false,
  officialUrl: 'https://ncees.org/licensure/international-professionals/',
  steps: [
    'Create a MyNCEES account and an NCEES Record',
    'Have your academic credentials evaluated via NCEES Credentials Evaluations (most international degrees aren\'t EAC/ABET-accredited)',
    'Sit and pass the NCEES Fundamentals of Engineering (FE) exam',
    'Accrue the required supervised experience, then sit and pass the NCEES Principles and Practice of Engineering (PE) exam',
    'Apply to the licensing board in your target state, since requirements vary state to state',
  ],
);
const _aeEngGeneric = LedgerEntry(
  'Municipality registration',
  note: 'varies by emirate',
  confidence: LedgerConfidence.verified,
  mandatory: false,
  officialUrl: 'https://www.dm.gov.ae/municipality-business/dubai-engineering-qualification-system-guide/',
  steps: [
    'Register with the UAE Society of Engineers and with your home country\'s engineering association',
    'Accrue a minimum 3 years of post-graduation experience, with attested experience certificates',
    'Create an account on the Dubai Engineering Qualification System (or your emirate\'s equivalent) and add your education/experience records',
    'Select your accreditation, book an exam slot, and pay the fee',
    'Pass the relevant qualification exam (e.g. 70%+ for structural) to gain accreditation',
  ],
);
const _auEngMsa = LedgerEntry(
  'Engineers Australia (MSA)',
  note: 'QLD/VIC also require RPEQ-style registration to practise in prescribed areas',
  confidence: LedgerConfidence.verified,
  officialUrl: 'https://www.engineersaustralia.org.au/migrants/migration-skills-assessment',
  steps: [
    'Determine your assessment pathway (Accredited Qualifications or Competency Demonstration Report) based on your degree',
    'Gather required documents, including English language evidence',
    'Apply online through the Engineers Australia portal and pay the assessment fee',
    'Await the "Suitable" or "Not Suitable" outcome — 8–12 weeks, or 15–20 working days with priority processing',
    'Use your migration skills assessment outcome letter for your visa application',
  ],
);

/// Generic Chartered Engineer steps via the Engineering Council — the
/// specific member institution (ICE, IMechE, IET, etc.) varies by
/// discipline, but the process itself is the same regardless of which one.
const _ukEngSteps = [
  'Use your chosen institution\'s qualifications checker to confirm your academic profile meets the Chartered Engineer benchmark',
  'Apply online (or via paper application) once you meet the academic requirement',
  'Prepare evidence against the UK-SPEC competence framework',
  'Attend a professional review interview (around 45 minutes) — mandatory regardless of discipline, available internationally or virtually',
  'If successful, your institution forwards your name to the Engineering Council for registration',
];

OccupationLedgerRow _engineeringRow({
  required String occupation,
  required LedgerEntry sg,
  String? ukInstitution,
}) =>
    OccupationLedgerRow(
      occupation: occupation,
      byCountry: {
        'Canada': _caEngGeneric,
        'Australia': _auEngMsa,
        'New Zealand': _nzEngGeneric,
        'Germany': _deEngGeneric,
        'United Kingdom': LedgerEntry(
          'Engineering Council',
          note: ukInstitution == null ? 'voluntary Chartered status' : 'via $ukInstitution — voluntary',
          confidence: LedgerConfidence.verified,
          mandatory: false,
          officialUrl: 'https://www.imeche.org/membership-registration/become-a-member/chartered-engineer',
          steps: _ukEngSteps,
        ),
        'Netherlands': _nlEngGeneric,
        'Ireland': _ieEngGeneric,
        'Singapore': sg,
        'United States': _usEngGeneric,
        'United Arab Emirates': _aeEngGeneric,
      },
    );

final _civilEngineerRow = _engineeringRow(
  occupation: 'Civil Engineer',
  ukInstitution: 'ICE',
  sg: const LedgerEntry(
    'PEB',
    note: 'core branch',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www1.peb.gov.sg/pe-registration/',
    steps: [
      'Hold an approved engineering degree in your branch',
      'Sit and pass the Fundamentals of Engineering Examination (FEE)',
      'Accrue at least 2 years 6 months of relevant practical experience',
      'Sit and pass the Practice of Professional Engineering Examination (PPE) for your branch',
      'Attend a professional interview, then receive your Practising Certificate — issued within 30 working days',
    ],
  ),
);
final _mechanicalEngineerRow = _engineeringRow(
  occupation: 'Mechanical Engineer',
  ukInstitution: 'IMechE',
  sg: const LedgerEntry(
    'PEB',
    note: 'core branch',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www1.peb.gov.sg/pe-registration/',
    steps: [
      'Hold an approved engineering degree in your branch',
      'Sit and pass the Fundamentals of Engineering Examination (FEE)',
      'Accrue at least 2 years 6 months of relevant practical experience',
      'Sit and pass the Practice of Professional Engineering Examination (PPE) for your branch',
      'Attend a professional interview, then receive your Practising Certificate — issued within 30 working days',
    ],
  ),
);
final _electricalEngineerRow = _engineeringRow(
  occupation: 'Electrical Engineer',
  ukInstitution: 'IET',
  sg: const LedgerEntry(
    'PEB',
    note: 'core branch',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www1.peb.gov.sg/pe-registration/',
    steps: [
      'Hold an approved engineering degree in your branch',
      'Sit and pass the Fundamentals of Engineering Examination (FEE)',
      'Accrue at least 2 years 6 months of relevant practical experience',
      'Sit and pass the Practice of Professional Engineering Examination (PPE) for your branch',
      'Attend a professional interview, then receive your Practising Certificate — issued within 30 working days',
    ],
  ),
);
final _electronicsEngineerRow = _engineeringRow(
  occupation: 'Electronics Engineer',
  ukInstitution: 'IET',
  sg: const LedgerEntry('Unclear vs. PEB "electrical"', note: 'branch boundary not explicit — confirm with PEB directly', confidence: LedgerConfidence.directional),
);
final _structuralEngineerRow = _engineeringRow(
  occupation: 'Structural Engineer',
  ukInstitution: 'IStructE or ICE',
  sg: const LedgerEntry('Likely within PEB civil branch', note: 'not a separate PEB branch — confirm directly', confidence: LedgerConfidence.directional),
);
final _chemicalEngineerRow = _engineeringRow(
  occupation: 'Chemical Engineer',
  ukInstitution: 'IChemE',
  sg: const LedgerEntry(
    'PEB',
    note: 'core branch',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www1.peb.gov.sg/pe-registration/',
    steps: [
      'Hold an approved engineering degree in your branch',
      'Sit and pass the Fundamentals of Engineering Examination (FEE)',
      'Accrue at least 2 years 6 months of relevant practical experience',
      'Sit and pass the Practice of Professional Engineering Examination (PPE) for your branch',
      'Attend a professional interview, then receive your Practising Certificate — issued within 30 working days',
    ],
  ),
);
final _miningEngineerRow = _engineeringRow(
  occupation: 'Mining Engineer',
  ukInstitution: 'IOM3',
  sg: const LedgerEntry('Not a PEB core/specialist branch', note: 'may overlap the geotechnical specialist branch — confirm directly', confidence: LedgerConfidence.directional),
);
final _automotiveEngineerRow = _engineeringRow(
  occupation: 'Automotive Engineer',
  ukInstitution: 'IMechE',
  sg: const LedgerEntry('Not a separate PEB branch', note: 'may sit within mechanical — confirm directly', confidence: LedgerConfidence.directional),
);
final _processEngineerRow = _engineeringRow(
  occupation: 'Process Engineer',
  ukInstitution: 'IChemE',
  sg: const LedgerEntry('Likely within PEB chemical branch', confidence: LedgerConfidence.directional),
);
final _renewableEnergyTechnicianRow = _engineeringRow(
  occupation: 'Renewable Energy Technician',
  sg: const LedgerEntry('Not a PEB branch', note: 'technician-tier role — confirm directly', confidence: LedgerConfidence.directional),
);
final _hardwareSiliconEngineerRow = _engineeringRow(
  occupation: 'Hardware / Silicon Engineer',
  ukInstitution: 'IET',
  sg: const LedgerEntry('Not a PEB branch', confidence: LedgerConfidence.directional),
);
final _roboticsSpecialistRow = _engineeringRow(
  occupation: 'Robotics Specialist',
  sg: const LedgerEntry('Not a PEB branch', confidence: LedgerConfidence.directional),
);

// ---------------------------------------------------------------------
// Trades
// ---------------------------------------------------------------------

const _auTradeGeneric = LedgerEntry(
  'TRA (visa)',
  confidence: LedgerConfidence.verified,
  officialUrl: 'https://www.tradesrecognitionaustralia.gov.au/skills-assessment',
  steps: [
    'Confirm your trade is on the relevant occupation list and you meet the qualification/experience requirement',
    'Choose the right pathway: Migration Skills Assessment (MSA), Job Ready Program (JRP), RPL, or Offshore Skills Assessment (OSAP)',
    'Apply online via a TRA-approved assessing authority with your qualifications, employment history, and job duties',
    'Await your outcome — suitable, not suitable, or provisional — typically up to 120 days for MSA',
  ],
);
const _nzTradeGeneric = LedgerEntry(
  'NZQA',
  confidence: LedgerConfidence.verified,
  officialUrl: 'https://www2.nzqa.govt.nz/international/recognise-overseas-qual/apply-iqa/',
  steps: [
    'Check whether you need an International Qualification Assessment (IQA) for your situation',
    'Submit your application with evidence your qualification documents are genuine',
    'NZQA verifies your qualification\'s status and quality assurance in its awarding country, then compares it to the NZ Qualifications and Credentials Framework',
    'Receive your electronic recognition statement — standard processing is 20 working days',
  ],
);
const _deTradeGeneric = LedgerEntry(
  'HWK',
  confidence: LedgerConfidence.verified,
  officialUrl: 'https://www.hwk.de/english/',
  steps: [
    'Book a consultation with your regional Handwerkskammer (Chamber of Crafts)',
    'Bring ID, training credentials, German translations, and a tabular CV in German',
    'Submit an application for equivalence determination against the German reference occupation',
    'Receive full equivalence, partial equivalence (with an adaptation measure), or non-equivalence — typically 3 weeks to 3 months',
  ],
);
const _ukTradeGeneric = LedgerEntry(
  'UK ENIC',
  confidence: LedgerConfidence.verified,
  officialUrl: 'https://www.enic.org.uk/individuals/statement-of-comparability',
  steps: [
    'Create an online UK ENIC account and verify your email',
    'Add your qualification and upload your final certificate and official transcript',
    'Provide certified translations if your documents aren\'t in English',
    'Receive your Statement of Comparability — around 15 working days',
  ],
);
const _nlTradeGeneric = LedgerEntry(
  'SBB',
  confidence: LedgerConfidence.verified,
  officialUrl: 'https://www.s-bb.nl/en/companies/credential-evaluation',
  steps: [
    'Identify your route: via an ROC (vocational college), the UWV (if on unemployment benefits), or directly via the Diploma Valuation Information Centre (IcDW)',
    'Submit your foreign diploma for evaluation by SBB\'s International Diploma Assessment Centres',
    'Receive a credential evaluation describing which Dutch qualification your diploma compares to',
  ],
);
const _ieTradeGeneric = LedgerEntry(
  'QQI',
  confidence: LedgerConfidence.verified,
  officialUrl: 'https://www.qqi.ie/recognition-of-foreign-qualifications',
  steps: [
    'Search NARIC Ireland\'s free Foreign Qualifications Database by the country where you were awarded your qualification',
    'Download your comparability statement, comparing your qualification to Ireland\'s National Framework of Qualifications',
    'If your qualification isn\'t listed, apply for individual advice on general academic recognition',
  ],
);
const _sgTradeGeneric = LedgerEntry('Not typically required', confidence: LedgerConfidence.verified, applicable: false);
const _redSealUrl = 'https://red-seal.ca/eng/about/program.shtml';
const _redSealSteps = [
  'Contact your provincial trades authority (e.g. TSSA in Ontario, ABSA in Alberta) for a credential assessment',
  'Provide original trade certificates, employer reference letters, translated documents, and an Educational Credential Assessment (ECA)',
  'Receive a decision — full equivalency (write the exam directly), partial credit with a learning plan, or additional training required',
  'Sit the Red Seal exam (100–150 multiple-choice questions, 4 hours, 70% pass mark)',
  'Receive the Red Seal endorsement on your provincial/territorial trade certificate',
];
const _aeTradeGeneric = LedgerEntry(
  'MOHRE classification',
  confidence: LedgerConfidence.verified,
  officialUrl: 'https://www.mohre.gov.ae/en/job-descriptions',
  steps: [
    'Confirm your certificate is higher than secondary level and attested by the competent authorities',
    'Confirm your salary meets the minimum threshold for skilled classification (currently AED 4,000/month)',
    'Have your employer register your occupational classification with MOHRE as part of your work permit',
    'Check your classification and digital permit via MOHRE\'s inquiry service using your passport and permit number',
  ],
);

const _electricianRow = OccupationLedgerRow(
  occupation: 'Electrician',
  byCountry: {
    'Canada': LedgerEntry('Red Seal', note: '+ provincial electrical licence required to work', confidence: LedgerConfidence.verified, officialUrl: _redSealUrl, steps: _redSealSteps),
    'Australia': LedgerEntry(
      'TRA (visa) + state licence',
      note: 'e.g. NSW electrical licence, Energy Safe Victoria',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.nsw.gov.au/business-and-economy/licences-and-credentials/building-and-trade-licences-and-registrations/electrical',
      steps: [
        'Complete the TRA skills assessment (see above) for the migration side',
        'Separately, obtain a Certificate of Proficiency from your state\'s vocational training review panel (e.g. NSW VTRP)',
        'Accrue at least 12 months of relevant electrical wiring experience under the local wiring rules (AS/NZS 3000)',
        'If licensed interstate already, apply for mutual recognition in person at your target state\'s licensing office',
      ],
    ),
    'New Zealand': LedgerEntry('NZQA + practice board', note: 'likely a separate electrical-worker licensing board — confirm directly', confidence: LedgerConfidence.directional),
    'Germany': _deTradeGeneric,
    'United Kingdom': LedgerEntry(
      'UK ENIC + NICEIC scheme',
      note: 'competent-person self-certification',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://niceic.com/for-the-trades-1/professional-standards/schemes/competent-person-register/',
      steps: [
        'Get your qualification compared via UK ENIC (see above)',
        'Submit your NICEIC scheme application and review fee',
        'Hold at least £2 million Public Liability insurance if working in domestic dwellings',
        'Pass an in-person assessment of your qualifications, test instruments, and technical knowledge (BS 7671)',
        'Receive certification — typically 4–8 weeks from application to registration',
      ],
    ),
    'Netherlands': _nlTradeGeneric,
    'Ireland': _ieTradeGeneric,
    'Singapore': _sgTradeGeneric,
    'United States': LedgerEntry('Varies by state', note: 'some states license individuals, some only contractors, some leave it to localities', confidence: LedgerConfidence.verified),
    'United Arab Emirates': _aeTradeGeneric,
  },
);

const _industrialElectricianRow = OccupationLedgerRow(
  occupation: 'Industrial Electrician',
  byCountry: {
    'Canada': LedgerEntry('Red Seal', note: 'same base trade; industrial settings may sit under workplace OHS rules instead', confidence: LedgerConfidence.verified, officialUrl: _redSealUrl, steps: _redSealSteps),
    'Australia': LedgerEntry('TRA (visa) + state licence', note: 'same as Electrician', confidence: LedgerConfidence.directional),
    'New Zealand': LedgerEntry('NZQA + practice board', confidence: LedgerConfidence.directional),
    'Germany': _deTradeGeneric,
    'United Kingdom': LedgerEntry('UK ENIC + NICEIC scheme', confidence: LedgerConfidence.directional),
    'Netherlands': _nlTradeGeneric,
    'Ireland': _ieTradeGeneric,
    'Singapore': _sgTradeGeneric,
    'United States': LedgerEntry('Varies by state', confidence: LedgerConfidence.directional),
    'United Arab Emirates': _aeTradeGeneric,
  },
);

const _plumberRow = OccupationLedgerRow(
  occupation: 'Plumber',
  byCountry: {
    'Canada': LedgerEntry('Red Seal', note: '+ provincial plumbing licence required to work', confidence: LedgerConfidence.verified, officialUrl: _redSealUrl, steps: _redSealSteps),
    'Australia': LedgerEntry(
      'TRA (visa) + state licence',
      note: 'e.g. NSW/VBA plumbing licence',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.nsw.gov.au/business-and-economy/licences-and-credentials/building-and-trade-licences-and-registrations',
      steps: [
        'Complete the TRA skills assessment (see above) for the migration side',
        'Obtain a Certificate of Proficiency as a plumber from your state\'s vocational training review panel',
        'Accrue the required period of relevant plumbing work experience',
        'Apply directly to your state\'s licensing authority (e.g. NSW Fair Trading, VBA in Victoria) for your individual plumbing licence',
      ],
    ),
    'New Zealand': LedgerEntry('NZQA + PGDB', note: 'Plumbers, Gasfitters and Drainlayers Board — confirm directly', confidence: LedgerConfidence.directional),
    'Germany': _deTradeGeneric,
    'United Kingdom': LedgerEntry(
      'UK ENIC + Gas Safe Register',
      note: 'mandatory for gas-related work',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.gassaferegister.co.uk/services/becoming-registered/path-to-gas-safe-registration/',
      steps: [
        'Get your qualification compared via UK ENIC (see above)',
        'Hold an ACS Core Domestic Gas Safety (CCN1) qualification plus assessments for the specific appliances you\'ll work on',
        'Create a Gas Safe Register account and apply online with your qualification evidence and business details',
        'Pay the registration fee and receive your Gas Safe ID card',
        'Complete a 3-month probation period, keeping records of all gas work',
      ],
    ),
    'Netherlands': _nlTradeGeneric,
    'Ireland': _ieTradeGeneric,
    'Singapore': _sgTradeGeneric,
    'United States': LedgerEntry('Varies by state', confidence: LedgerConfidence.verified),
    'United Arab Emirates': _aeTradeGeneric,
  },
);

const _carpenterRow = OccupationLedgerRow(
  occupation: 'Carpenter',
  byCountry: {
    'Canada': LedgerEntry('Red Seal', confidence: LedgerConfidence.verified, officialUrl: _redSealUrl, steps: _redSealSteps),
    'Australia': LedgerEntry('TRA (visa)', note: 'builder/contractor licence only needed if quoting jobs directly', confidence: LedgerConfidence.directional),
    'New Zealand': _nzTradeGeneric,
    'Germany': _deTradeGeneric,
    'United Kingdom': LedgerEntry('UK ENIC', note: 'no gas/electrical-style overlay', confidence: LedgerConfidence.directional),
    'Netherlands': _nlTradeGeneric,
    'Ireland': _ieTradeGeneric,
    'Singapore': _sgTradeGeneric,
    'United States': LedgerEntry('Varies by state', note: 'generally lighter-touch than electrician/plumber', confidence: LedgerConfidence.directional),
    'United Arab Emirates': _aeTradeGeneric,
  },
);

const _welderRow = OccupationLedgerRow(
  occupation: 'Welder',
  byCountry: {
    'Canada': LedgerEntry('Red Seal', confidence: LedgerConfidence.verified, officialUrl: _redSealUrl, steps: _redSealSteps),
    'Australia': _auTradeGeneric,
    'New Zealand': _nzTradeGeneric,
    'Germany': _deTradeGeneric,
    'United Kingdom': _ukTradeGeneric,
    'Netherlands': _nlTradeGeneric,
    'Ireland': _ieTradeGeneric,
    'Singapore': _sgTradeGeneric,
    'United States': LedgerEntry('No state licence', note: 'AWS certification is the real employer-facing credential', confidence: LedgerConfidence.directional, applicable: false),
    'United Arab Emirates': _aeTradeGeneric,
  },
);

const _metalFitterRow = OccupationLedgerRow(
  occupation: 'Metal Fitter',
  byCountry: {
    'Canada': LedgerEntry('Red Seal', note: 'exact title/trade match not confirmed this pass', confidence: LedgerConfidence.directional, officialUrl: _redSealUrl, steps: _redSealSteps),
    'Australia': _auTradeGeneric,
    'New Zealand': _nzTradeGeneric,
    'Germany': _deTradeGeneric,
    'United Kingdom': _ukTradeGeneric,
    'Netherlands': _nlTradeGeneric,
    'Ireland': _ieTradeGeneric,
    'Singapore': _sgTradeGeneric,
    'United States': LedgerEntry('No state licence typically', confidence: LedgerConfidence.directional, applicable: false),
    'United Arab Emirates': _aeTradeGeneric,
  },
);

const _motorMechanicRow = OccupationLedgerRow(
  occupation: 'Motor Mechanic',
  byCountry: {
    'Canada': LedgerEntry('Red Seal', note: 'Automotive Service Technician', confidence: LedgerConfidence.verified, officialUrl: _redSealUrl, steps: _redSealSteps),
    'Australia': LedgerEntry('TRA (visa)', note: 'workshop may need a repairer business licence, not the individual', confidence: LedgerConfidence.directional),
    'New Zealand': _nzTradeGeneric,
    'Germany': _deTradeGeneric,
    'United Kingdom': _ukTradeGeneric,
    'Netherlands': _nlTradeGeneric,
    'Ireland': _ieTradeGeneric,
    'Singapore': _sgTradeGeneric,
    'United States': LedgerEntry('No state licence typically', note: 'ASE certification often employer-required, not government-issued', confidence: LedgerConfidence.directional, applicable: false),
    'United Arab Emirates': _aeTradeGeneric,
  },
);

const _dieselMechanicRow = OccupationLedgerRow(
  occupation: 'Diesel Mechanic (Heavy Vehicle)',
  byCountry: {
    'Canada': LedgerEntry('Red Seal', note: 'Heavy Duty Equipment Technician', confidence: LedgerConfidence.verified, officialUrl: _redSealUrl, steps: _redSealSteps),
    'Australia': _auTradeGeneric,
    'New Zealand': _nzTradeGeneric,
    'Germany': _deTradeGeneric,
    'United Kingdom': _ukTradeGeneric,
    'Netherlands': _nlTradeGeneric,
    'Ireland': _ieTradeGeneric,
    'Singapore': _sgTradeGeneric,
    'United States': LedgerEntry('No state licence typically', confidence: LedgerConfidence.directional, applicable: false),
    'United Arab Emirates': _aeTradeGeneric,
  },
);

/// The trades category's biggest correction: aircraft maintenance is
/// safety-of-flight work, so every country hands it to the same national
/// aviation authority that licenses pilots — not the generic trades body.
const _aircraftMechanicRow = OccupationLedgerRow(
  occupation: 'Aircraft Mechanic',
  byCountry: {
    'Canada': LedgerEntry('Transport Canada', note: 'AME licence, not Red Seal', confidence: LedgerConfidence.verified),
    'Australia': LedgerEntry('CASA', note: 'not TRA', confidence: LedgerConfidence.verified),
    'New Zealand': LedgerEntry('CAA NZ', note: 'not NZQA', confidence: LedgerConfidence.verified),
    'Germany': LedgerEntry('LBA', note: 'not HWK', confidence: LedgerConfidence.verified),
    'United Kingdom': LedgerEntry('UK CAA', note: 'not UK ENIC', confidence: LedgerConfidence.verified),
    'Netherlands': LedgerEntry('ILT', note: 'not SBB', confidence: LedgerConfidence.verified),
    'Ireland': LedgerEntry('IAA', note: 'not QQI', confidence: LedgerConfidence.verified),
    'Singapore': LedgerEntry('CAAS', note: 'not "unregulated"', confidence: LedgerConfidence.verified),
    'United States': LedgerEntry('FAA — A&P certificate', note: 'federal & uniform, not state-by-state', confidence: LedgerConfidence.verified),
    'United Arab Emirates': LedgerEntry('GCAA', note: 'not MOHRE', confidence: LedgerConfidence.verified),
  },
);

const _hvacSpecialistRow = OccupationLedgerRow(
  occupation: 'HVAC Specialist',
  byCountry: {
    'Canada': LedgerEntry('Red Seal', note: 'Refrigeration & A/C Mechanic', confidence: LedgerConfidence.verified, officialUrl: _redSealUrl, steps: _redSealSteps),
    'Australia': LedgerEntry(
      'TRA (visa) + ARCtick',
      note: 'federal refrigerant-handling licence mandatory regardless of state trade licence',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.arctick.org/refrigerant-handling-licence/',
      steps: [
        'Complete a Certificate III in Air Conditioning and Refrigeration (or current equivalent) including refrigerant-handling competency units',
        'Apply to the Australian Refrigeration Council online, with evidence of your qualification and a compliant photo',
        'Pay the application fee and submit all supporting documentation',
        'Await your Refrigerant Handling Licence — up to 30 days processing',
      ],
    ),
    'New Zealand': LedgerEntry('NZQA + refrigerant cert', confidence: LedgerConfidence.directional),
    'Germany': _deTradeGeneric,
    'United Kingdom': LedgerEntry('UK ENIC + Gas Safe / F-Gas cert', note: 'if handling gas-fired systems or refrigerants', confidence: LedgerConfidence.directional),
    'Netherlands': _nlTradeGeneric,
    'Ireland': _ieTradeGeneric,
    'Singapore': _sgTradeGeneric,
    'United States': LedgerEntry(
      'Varies by state + EPA 608',
      note: 'federal refrigerant-handling cert mandatory nationwide',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.epa.gov/section608/section-608-technician-certification',
      steps: [
        'Determine which certification type you need: Type I (small appliances), Type II (high/very-high pressure), Type III (low pressure), or Universal (all types)',
        'Sit an EPA-approved test through an EPA-approved certifying organization',
        'Pass the test — Section 608 certification doesn\'t expire once earned',
        'Separately check your target state\'s own HVAC trade licensing requirements, since these vary state to state',
      ],
    ),
    'United Arab Emirates': _aeTradeGeneric,
  },
);

const _mechatronicsTechnicianRow = OccupationLedgerRow(
  occupation: 'Mechatronics Technician',
  byCountry: {
    'Canada': LedgerEntry('Red Seal', note: 'a newer trade addition — exact status not confirmed this pass', confidence: LedgerConfidence.directional, officialUrl: _redSealUrl, steps: _redSealSteps),
    'Australia': _auTradeGeneric,
    'New Zealand': _nzTradeGeneric,
    'Germany': LedgerEntry('HWK', confidence: LedgerConfidence.directional),
    'United Kingdom': _ukTradeGeneric,
    'Netherlands': _nlTradeGeneric,
    'Ireland': _ieTradeGeneric,
    'Singapore': _sgTradeGeneric,
    'United States': LedgerEntry('No state licence typically', confidence: LedgerConfidence.directional, applicable: false),
    'United Arab Emirates': _aeTradeGeneric,
  },
);

// ---------------------------------------------------------------------
// Education
// ---------------------------------------------------------------------

final Map<String, LedgerEntry> _primaryTeacherEntries = {
  'Canada': const LedgerEntry(
    'Provincial teaching body',
    note: 'e.g. Ontario College of Teachers',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www.oct.ca/becoming-a-teacher/internationally-educated-teachers',
    steps: [
      'Complete the College\'s self-assessment tool',
      'Register on the online portal, pay the application fee, and receive your file/reference number',
      'Have a Statement of Professional Standing sent directly to the College from every jurisdiction you\'ve taught in',
      'Provide transcripts, a criminal record check, and a language test if you weren\'t trained in English or French',
      'Submit within your one-year application window — you\'ll get a document status page within 10 business days of a complete application',
    ],
  ),
  'Australia': const LedgerEntry(
    'AITSL + state authority',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www.aitsl.edu.au/migrate-to-australia/apply-for-a-skills-assessment',
    steps: [
      'Confirm you have 4+ years of full-time equivalent study including an initial teacher education qualification',
      'Meet the English requirement — Academic IELTS 7.0 in reading/writing, 8.0 in speaking/listening',
      'Choose the checklist matching your teaching occupation and gather the required documents',
      'Submit via the AITSL Applicant Portal — most complete applications process in 4–6 weeks',
      'Separately register with the teacher registration authority in the state/territory where you\'ll actually teach',
    ],
  ),
  'New Zealand': const LedgerEntry(
    'Teaching Council of Aotearoa NZ',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://teachingcouncil.nz/en/become-a-teacher/overseas-trained-teacher-coming-to-Aotearoa/register-to-teach-as-an-overseas-teacher',
    steps: [
      'Set up a My Rawa login and an Educator Sector Login (ESL)',
      'Apply for a teaching International Qualifications Assessment (IQA) if needed',
      'Gather qualification transcripts, English evidence, police clearance, and statements of professional standing',
      'Submit your registration and first practising certificate application together via My Rawa',
      'Await police vetting and document review — 6–12 weeks, longer if a panel review is required',
    ],
  ),
  'Germany': const LedgerEntry(
    'State Ministry of Education',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www.anerkennung-in-deutschland.de/',
    steps: [
      'Submit your application to the responsible state ministry office (e.g. Berlin\'s Senate Department for Education)',
      'Provide evidence of your qualification, training content/duration, and teaching experience',
      'Get German translations from a sworn translator for any non-German documents',
      'Await the equivalence assessment, comparing your training content, duration, and subjects taught against the state\'s standard',
    ],
  ),
  'United Kingdom': const LedgerEntry(
    'Teaching Regulation Agency',
    note: 'QTS',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www.gov.uk/government/publications/apply-for-qualified-teacher-status-qts-if-you-teach-outside-the-uk',
    steps: [
      'Confirm your bachelor\'s degree is verified as UK-equivalent by UK ENIC',
      'Confirm you hold full professional teaching status in your training country',
      'Choose your route: Apply for QTS in England, Assessment Only QTS, a teacher training course, or international QTS (iQTS)',
      'Complete your chosen route\'s specific requirements',
      'Note QTS alone doesn\'t grant a job or visa — apply for teaching posts and visas separately',
    ],
  ),
  'Netherlands': const LedgerEntry(
    'DUO',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://duo.nl/particulier/foreign-diploma-in-the-netherlands/working-as-a-teacher.jsp',
    steps: [
      'Confirm you completed teacher training at Dutch higher-professional level or above, and are authorised to teach where you trained',
      'Use the correct DUO form: EU professional teaching qualifications, or non-EU',
      'Apply online for the fastest processing (paper forms take considerably longer)',
      'Await DUO\'s recognition decision matching your authorisation to the Dutch equivalent',
    ],
  ),
  'Ireland': const LedgerEntry(
    'Teaching Council of Ireland',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www.teachingcouncil.ie/i-am-applying-to-register/qualified-outside-of-ireland/',
    steps: [
      'Identify your registration route (Primary, Post-Primary, or Route 4 – Other) via the My Registration portal',
      'Upload transcripts, degree certificates, and teacher education qualification evidence in English or Irish (certified translations otherwise)',
      'Complete your application within 3 months of starting it, or it\'s deleted',
      'Await the Council\'s comparability assessment — up to 12 weeks — noting any qualification shortfalls that attach conditions to your registration',
    ],
  ),
  'Singapore': const LedgerEntry(
    'MOE',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www.moe.gov.sg/careers/become-teachers',
    steps: [
      'Submit a detailed CV, qualification documents, and statement of purpose to MOE',
      'Pay the registration fee (roughly SGD 100–300)',
      'Await MOE processing — 1 to 6 months',
      'Secure the relevant work pass (typically an Employment Pass via the Ministry of Manpower) separately',
    ],
  ),
  'United States': const LedgerEntry(
    'State Dept. of Education',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://www.uslanguageservices.com/guides-resources/how-to-work-in-the-us-as-a-foreign-educated-teacher/',
    steps: [
      'Have your credentials evaluated by a NACES or AICE member service',
      'Confirm you meet the degree requirement for your target state (bachelor\'s minimum; some states require a master\'s)',
      'Complete a state-approved teacher preparation program if required',
      'Pass your state\'s certification exams (e.g. Praxis)',
      'Submit your certification application, documents, and fee to your target state\'s education department',
    ],
  ),
  'United Arab Emirates': const LedgerEntry(
    'Federal TLS + emirate regulator',
    confidence: LedgerConfidence.verified,
    officialUrl: 'https://tls.moe.gov.ae/',
    steps: [
      'Have your qualifications attested: issuing country\'s education authority, then the UAE Embassy/Consulate, then UAE MOFA',
      'Register on the TLS portal with your personal, passport, and attested qualification details',
      'Await document review and credential/reference verification',
      'Register for and pass the Pedagogy Test and the Subject-specific Test',
      'Receive your digital teaching licence — valid 3 years, renewable with ongoing professional development',
    ],
  ),
};

final _primaryTeacherRow = OccupationLedgerRow(occupation: 'Primary School Teacher', byCountry: _primaryTeacherEntries);

LedgerEntry _sameAsPrimary(String country, String noteSuffix) {
  final base = _primaryTeacherEntries[country]!;
  return LedgerEntry(
    'Same as Primary Teacher',
    note: noteSuffix,
    confidence: LedgerConfidence.verified,
    officialUrl: base.officialUrl,
    steps: base.steps,
  );
}

OccupationLedgerRow _sameAsPrimaryRow(String occupation, String noteSuffix) => OccupationLedgerRow(
      occupation: occupation,
      byCountry: {
        for (final c in _countries) c: _sameAsPrimary(c, noteSuffix),
      },
    );

final _secondaryTeacherRow = _sameAsPrimaryRow('Secondary School Teacher', 'same statutory body as Primary');
final _specialNeedsTeacherRow = _sameAsPrimaryRow(
  'Special Needs Teacher',
  'same body as Primary, usually plus a specialist endorsement or postgraduate qualification',
);

const _earlyChildhoodTeacherRow = OccupationLedgerRow(
  occupation: 'Early Childhood Teacher',
  byCountry: {
    'Canada': LedgerEntry(
      'Separate ECE college',
      note: 'e.g. College of ECE (Ontario) — not the Teachers\' college',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://college-ece.ca/applicants/how-to-apply/',
      steps: [
        'Have your international education and work experience individually assessed by the College if it isn\'t already recognised',
        'Submit official transcripts, proof of practicum experience, and background checks',
        'Provide language proficiency test results if required',
        'Complete the online application via the College\'s Applicants portal',
      ],
    ),
    'Australia': LedgerEntry(
      'Varies by state',
      note: 'mandatory in SA/WA/NSW/VIC regardless of setting; school-only in ACT/TAS/NT',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.acecqa.gov.au/qualifications-0/early-childhood-teacher-registration-and-accreditation',
      steps: [
        'Confirm your qualification is ACECQA-approved for birth-to-five early childhood teaching',
        'Apply for Conditional/Provisional registration with your state\'s authority (e.g. NESA in NSW via eTAMS, VIT in Victoria)',
        'Complete your state\'s suitability checks',
        'Progress to full/proficient registration after the required supervised teaching days and observations (e.g. 80 days in Victoria)',
        'Renew periodically with evidence of ongoing teaching and professional learning',
      ],
    ),
    'New Zealand': LedgerEntry('Teaching Council of NZ', note: 'believed unified across ECE–secondary — confirm directly', confidence: LedgerConfidence.directional),
    'Germany': LedgerEntry(
      'Erzieher/in',
      note: 'separate vocational Ausbildung, not the academic Lehramt route',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.anerkennung-in-deutschland.de/',
      steps: [
        'Use the Recognition Finder to find your state\'s competent authority for educator qualifications',
        'Submit your qualification for equivalence determination against the German Erzieher/in standard',
        'Reach C1-level German — required for state recognition as an educator',
        'Meet personal- and health-suitability requirements',
        'Await the equivalence decision — up to 3 months',
      ],
    ),
    'United Kingdom': LedgerEntry('Not required', note: 'Ofsted registers the setting, not the individual practitioner', confidence: LedgerConfidence.verified, applicable: false),
    'Netherlands': LedgerEntry('Likely a separate pedagogical qualification', note: 'not the school "bevoegdheid" — confirm directly', confidence: LedgerConfidence.directional),
    'Ireland': LedgerEntry('Not Teaching-Council registered', note: 'early years services regulated via Tusla/DCEDIY instead', confidence: LedgerConfidence.directional),
    'Singapore': LedgerEntry(
      'ECDA',
      note: 'Early Childhood Development Agency — separate from MOE',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.ecda.gov.sg/early-childhood-educators-(ece)/becoming-a-certified-educator/educator-certification/foreign-early-childhood-qualifications',
      steps: [
        'Use the ONE@ECDA self-assessment tool to preliminarily check your qualification (optional, not the formal outcome)',
        'Have your employing centre — or your own ONE@ECDA account — submit your certification application',
        'Provide verification proof for your foreign qualification from a global verification agency when requested',
        'Complete the mandatory "Cultural Compass" course if you hold a foreign EC qualification',
        'Receive ECDA\'s Letter of Notification confirming your certification level',
      ],
    ),
    'United States': LedgerEntry('Varies hugely by state/setting', note: 'often just a CDA credential rather than a full teaching licence', confidence: LedgerConfidence.directional),
    'United Arab Emirates': LedgerEntry('Likely separate nursery-sector rules', note: 'not confirmed this pass', confidence: LedgerConfidence.directional),
  },
);

// ---------------------------------------------------------------------
// Transport
// ---------------------------------------------------------------------

const _commercialPilotRow = OccupationLedgerRow(
  occupation: 'Commercial Pilot',
  byCountry: {
    'Canada': LedgerEntry(
      'Transport Canada',
      note: 'Civil Aviation — licence validation/conversion',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://tc.canada.ca/en/aviation/licensing-pilots-personnel/flight-crew-licences-permits-ratings/licensing-foreign-pilots',
      steps: [
        'For short-term flying: apply for a Foreign Licence Validation Certificate (FLVC) — licence, medical, passport, English test, up to 20 days to process',
        'For a permanent licence: hold a Category 1 Medical Certificate and provide flight logbook evidence of experience',
        'Sit any required knowledge exams for your licence level',
        'Complete Form 26-0702 (conversion) and Form 26-0726 (Aviation Document Booklet)',
      ],
    ),
    'Australia': LedgerEntry(
      'CASA',
      note: 'Civil Aviation Safety Authority',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.casa.gov.au/licences-and-certificates/pilots/pilot-licences/military-and-international-licences/converting-overseas-flight-crew-licence',
      steps: [
        'Obtain an Aviation Reference Number (ARN) from CASA',
        'Submit form 61-4A (Flight crew licence application) — CASA verifies your licence with the issuing authority, up to 4 weeks',
        'Complete an Australian aviation medical and ASIC security clearance',
        'Sit an English language assessment if required',
        'For CPL/MPL/ATPL: pass conversion exams and a flight test',
        'Complete a flight review with an authorised instructor to activate the licence',
      ],
    ),
    'New Zealand': LedgerEntry(
      'CAA NZ',
      note: 'Civil Aviation Authority',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.aviation.govt.nz/licensing-and-certification/pilots/pilot-licensing/recognising-foreign-pilot-licences/',
      steps: [
        'For short-term validation: hold ICAO ELP level 4+, and complete a NZ Biennial Flight Review if flying VFR privately',
        'For full conversion: meet Part 61 eligibility and flight experience requirements for your licence level',
        'Complete the Fit and Proper Persons Questionnaire, including criminal/traffic history checks',
        'Note validation permits max out at 6 months and can\'t exceed your foreign licence/medical expiry',
      ],
    ),
    'Germany': LedgerEntry(
      'LBA',
      note: 'Luftfahrt-Bundesamt',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.lba.de/EN/AviationPersonnel/Licensing/Licensing_node.html',
      steps: [
        'Have your foreign licence verified by its issuing authority (verification no older than 6 months)',
        'Provide an ICAO-standard medical certificate and evidence of 100 hours total flight time',
        'Complete a background check (Zuverlässigkeitsüberprüfung) and traffic offence record check',
        'Meet the language proficiency requirement in English or your radio-communication language',
        'Pass the theoretical exam covering Air Law and Human Performance',
        'Submit your application by email, fax, or post to the LBA — 4–6 weeks processing',
      ],
    ),
    'United Kingdom': LedgerEntry(
      'UK CAA',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.caa.co.uk/commercial-industry/pilot-licences/non-uk-licences/how-to-validate-your-icao-third-country-licence/',
      steps: [
        'Submit a certified copy of your valid ICAO third-country licence and medical certificate',
        'Complete the Third Country Verification application form (SRG2142)',
        'Hold a valid UK Part-MED medical certificate of the appropriate class',
        'Be assessed for English Language Proficiency at Level 4, 5, or 6',
        'Pass a class/type rating (and IR if applicable) skill test with a UK CAA-certified examiner',
      ],
    ),
    'Netherlands': LedgerEntry(
      'ILT',
      note: 'Inspectie Leefomgeving en Transport',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://english.ilent.nl/topics/aviation/individual-licences/pilots/aeroplane-pilots/converting-or-validating',
      steps: [
        'Complete the online "Application for ICAO to EASA licence conversion or validation" form',
        'Gather all required attachments before submitting — valid passport, Class 2 medical, theory exam results, language proficiency endorsement',
        'Provide logbook pages demonstrating your required flying hours',
        'Ensure your name and place of birth exactly match your passport',
      ],
    ),
    'Ireland': LedgerEntry(
      'IAA',
      note: 'Irish Aviation Authority',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.iaa.ie/personnel-licensing/pilot-licences-(eu-regulations)/recognition-of-3rd-country-licences',
      steps: [
        'For short-term non-commercial flying: apply for temporary validation (max 28 days/year, Day VFR PPL privileges only)',
        'Complete an acclimatisation flight with a qualified instructor before performing your first task',
        'For commercial operations: note there\'s no automatic ATPL conversion — apply for training credits toward full Part-FCL requirements instead',
      ],
    ),
    'Singapore': LedgerEntry(
      'CAAS',
      note: 'Civil Aviation Authority of Singapore',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.caas.gov.sg/personnel-licensing/flight-crew-pilot/foreign-pilot-licence-conversion/',
      steps: [
        'Submit an Application for Assessment of Foreign Licence Requirements (Part I) via CAPELS',
        'If eligible, submit an Application for a Pilot Licence through Foreign Licence Conversion (Part II)',
        'Sit the examinations and flight test(s) required under the Singapore Air Safety Publication Part 2, Chapter 11',
        'Have your foreign licence positively verified by its issuing authority before the Singapore licence is granted',
      ],
    ),
    'United States': LedgerEntry(
      'FAA',
      note: 'Federal Aviation Administration',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.faa.gov/licenses_certificates/airmen_certification/foreign_license_verification',
      steps: [
        'Hold a valid medical certificate meeting FAA criteria',
        'Create an IACRA account and start the Foreign License Verification Process, submitting AC Form 8060-71',
        'Wait for the FAA to verify your licence with your issuing civil aviation authority — 45 to 90 days',
        'Within 6 months of your Letter of Verification, meet in person with an FSDO inspector or Designated Pilot Examiner',
        'Have your English proficiency and medical certificate confirmed at that meeting before your certificate is issued',
      ],
    ),
    'United Arab Emirates': LedgerEntry(
      'GCAA',
      note: 'General Civil Aviation Authority',
      confidence: LedgerConfidence.verified,
      officialUrl: 'https://www.gcaa.gov.ae/en/epublication/Pages/licensingdirective.aspx',
      steps: [
        'Submit your application via the GCAA e-Services portal with your foreign licence, medical, passport, and logbook',
        'Obtain a verification letter from your licence-issuing state, confirming validity (valid only 3 months from issue)',
        'Obtain a GCAA Class 1 Medical from an approved Aeromedical Centre',
        'Sit GCAA-specific subjects (e.g. Air Law, Operational Procedures)',
        'Pass a licence skill test with a UAE-approved examiner — overall processing typically 4–8 weeks',
      ],
    ),
  },
);

// ---------------------------------------------------------------------
// Full ledger, by category
// ---------------------------------------------------------------------

final Map<OccupationCategory, List<OccupationLedgerRow>> occupationRegistrationLedger = {
  OccupationCategory.healthcare: [
    _doctorRow,
    _gpRow,
    _surgeonRow,
    _nurseRow,
    _medLabScientistRow,
    _pharmacistRow,
    _physiotherapistRow,
    _occupationalTherapistRow,
    _midwifeRow,
    _paramedicHealthcareRow,
    _clinicalPsychologistRow,
    _socialWorkerRow,
    _careWorkerRow('Senior Care Worker'),
    _careWorkerRow('Geriatric Caregiver / Aged Care Worker'),
    _careWorkerRow('Aged & Disability Support Worker'),
    _clinicalTrialManagerRow,
  ],
  OccupationCategory.engineering: [
    _civilEngineerRow,
    _mechanicalEngineerRow,
    _electricalEngineerRow,
    _electronicsEngineerRow,
    _structuralEngineerRow,
    _chemicalEngineerRow,
    _miningEngineerRow,
    _automotiveEngineerRow,
    _processEngineerRow,
    _renewableEnergyTechnicianRow,
    _hardwareSiliconEngineerRow,
    _roboticsSpecialistRow,
  ],
  OccupationCategory.trades: [
    _electricianRow,
    _industrialElectricianRow,
    _plumberRow,
    _carpenterRow,
    _welderRow,
    _metalFitterRow,
    _motorMechanicRow,
    _dieselMechanicRow,
    _aircraftMechanicRow,
    _hvacSpecialistRow,
    _mechatronicsTechnicianRow,
  ],
  OccupationCategory.education: [
    _earlyChildhoodTeacherRow,
    _primaryTeacherRow,
    _secondaryTeacherRow,
    _specialNeedsTeacherRow,
  ],
  OccupationCategory.transport: [
    _commercialPilotRow,
  ],
};

/// The occupation-specific answer for (occupation, country), when this
/// occupation has been researched individually — the source of truth over
/// the category-level default in registration_bodies.dart wherever both exist.
LedgerEntry? ledgerEntryFor(String occupation, String country) {
  for (final rows in occupationRegistrationLedger.values) {
    for (final row in rows) {
      if (row.occupation == occupation) return row.byCountry[country];
    }
  }
  return null;
}

const Map<OccupationCategory, String> occupationCategoryLabels = {
  OccupationCategory.healthcare: 'Healthcare',
  OccupationCategory.engineering: 'Engineering',
  OccupationCategory.trades: 'Skilled trades',
  OccupationCategory.education: 'Education',
  OccupationCategory.science: 'Science',
  OccupationCategory.business: 'Business',
  OccupationCategory.transport: 'Transport',
};

/// Only the categories that actually have a licensing/registration body
/// modelled — Science, Technology, and Business are unregulated across all
/// ten of our destination countries and have no ledger to show.
const List<OccupationCategory> licensedOccupationCategories = [
  OccupationCategory.healthcare,
  OccupationCategory.engineering,
  OccupationCategory.trades,
  OccupationCategory.education,
  OccupationCategory.transport,
];

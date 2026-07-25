/// Task/gap status — used by [PathwayTask] (see pathway_tasks.dart), which
/// derives real per-applicant progress from actual document uploads. The
/// sample task/gap content that used to live in this file was removed:
/// it showed identical canned progress to every applicant regardless of
/// what they'd actually done.
enum TaskStatus { verified, pending, rejected }

class SampleLandingItem {
  final String title;
  final String subtitle;
  final String description;

  const SampleLandingItem({
    required this.title,
    required this.subtitle,
    required this.description,
  });
}

/// Illustrative sample list only — not pulled from any live occupation
/// register. Curated from published shortage lists (Canada's Express Entry
/// categories, Australia's MLTSSL, NZ's Green List, Germany's Blue Card /
/// Chancenkarte shortage areas, the UK's Skilled Worker & Health and Care
/// visa lists, the Netherlands' Kennismigrant scheme, Singapore's COMPASS
/// framework, and the US H-1B/O-1/EB-2 NIW pipelines) — not a live-fetched
/// regulatory feed, so treat as directional rather than authoritative.
const occupationOptions = [
  // Healthcare
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

  // Engineering
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

  // Technology
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

  // Skilled trades
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

  // Education
  'Early Childhood Teacher',
  'Primary School Teacher',
  'Secondary School Teacher',
  'Special Needs Teacher',

  // Science
  'Biological Scientist',
  'Biochemist',
  'Mathematician',

  // Business, finance & management
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

  // Transport
  'Commercial Pilot',
];

/// Illustrative sample list of high-demand skilled-migration destinations,
/// combining the classic points-based PR countries (Canada, Australia, NZ),
/// Europe's fast-track hubs (Germany, UK, Netherlands, Ireland), the elite
/// corporate hubs (Singapore, US), and regional expat destinations (UAE) —
/// not a live-fetched regulatory list.
const targetCountryOptions = [
  'Canada',
  'Australia',
  'New Zealand',
  'Germany',
  'United Kingdom',
  'Netherlands',
  'Ireland',
  'Singapore',
  'United States',
  'United Arab Emirates',
];

const sampleLandingItems = [
  SampleLandingItem(
    title: 'Foreign bank account setup',
    subtitle: 'Compare pre-arrival account options',
    description:
        'Open a foreign bank account before you land so your salary, rent, and bills can be '
        'set up from day one. Compare account fees, minimum balance rules, and the documents '
        'each provider accepts from newly arrived skilled migrants.',
  ),
  SampleLandingItem(
    title: 'Mandatory visa health cover',
    subtitle: 'Compare provider tariffs side by side',
    description:
        'Most skilled visa pathways require proof of health cover before your visa is granted. '
        'Compare tariffs and coverage across approved providers so you can select a policy that '
        'satisfies your visa condition without overpaying.',
  ),
  SampleLandingItem(
    title: 'Job matching',
    subtitle: 'Where to actually look, for your occupation and destination',
    description:
        'A curated starting point rather than a live matching engine: the job boards, '
        'agencies, and public-sector portals most commonly used for your occupation in your '
        "destination country — e.g. Seek and Indeed in Australia, Job Bank in Canada, NHS "
        'Jobs for UK healthcare roles, or USAJobs for US public-sector work. Always verify '
        'a listing and employer directly before applying or paying anyone.',
  ),
  SampleLandingItem(
    title: 'Remittance comparison',
    subtitle: 'Send money home without losing it to fees',
    description:
        'Compare transfer fees, exchange-rate margins, and delivery speed across providers '
        'like Wise, Western Union, Remitly, and WorldRemit before your first transfer. Rates '
        'change constantly, so treat this as a checklist of what to compare, not live pricing '
        '— and be wary of any provider or "agent" that pressures you to send money urgently.',
  ),
];

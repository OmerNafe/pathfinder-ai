import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/countries.dart';
import '../services/auth_service.dart';
import '../state/profile_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/autocomplete_text_field.dart';
import '../widgets/floating_card.dart';
import '../widgets/page_shell.dart';
import '../widgets/phone_country_code_field.dart';
import '../widgets/section_title.dart';

const _defaultDialCode = '+974';

(String, String) _parsePhone(String phone) {
  final trimmed = phone.trim();
  if (trimmed.startsWith('+')) {
    final spaceIndex = trimmed.indexOf(' ');
    if (spaceIndex > 0) {
      return (trimmed.substring(0, spaceIndex), trimmed.substring(spaceIndex + 1).trim());
    }
  }
  return (_defaultDialCode, trimmed);
}

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final _originalEmail = ref.read(profileProvider).email;
  bool _saving = false;
  late final _nameController = TextEditingController(text: ref.read(profileProvider).fullName);
  late final _emailController = TextEditingController(text: ref.read(profileProvider).email);
  late final _initialPhoneParts = _parsePhone(ref.read(profileProvider).phone);
  late String _dialCode = _initialPhoneParts.$1;
  late final _phoneController = TextEditingController(text: _initialPhoneParts.$2);
  late final _nationalityController =
      TextEditingController(text: ref.read(profileProvider).nationality);
  late final _residenceController =
      TextEditingController(text: ref.read(profileProvider).countryOfResidence);
  late final _experienceController = TextEditingController(
    text: ref.read(profileProvider).yearsOfExperience?.toString() ?? '',
  );
  late DateTime? _dateOfBirth = ref.read(profileProvider).dateOfBirth;
  late String _maritalStatus = ref.read(profileProvider).maritalStatus;
  late String _highestQualification = ref.read(profileProvider).highestQualification;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalityController.dispose();
    _residenceController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppColors.backgroundElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 30),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 16),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final newEmail = _emailController.text.trim();
    final emailChanged = newEmail.isNotEmpty && newEmail != _originalEmail;

    if (emailChanged) {
      try {
        await AuthService.updateEmail(newEmail);
      } on AppAuthException catch (e) {
        if (!mounted) return;
        setState(() => _saving = false);
        AppSnackBar.show(context, e.message);
        return;
      }
    }

    final phoneNumber = _phoneController.text.trim();
    final phone = phoneNumber.isEmpty ? '' : '$_dialCode $phoneNumber';

    ref.read(profileProvider.notifier).updateDetails(
          fullName: _nameController.text,
          // profiles has no email column -- auth.users' own email (just
          // updated above, if it changed) is the real source of truth.
          // Keep local state as whatever it already was until that change
          // is confirmed, rather than optimistically showing the
          // unconfirmed new address as if it were already active.
          email: _originalEmail,
          phone: phone,
          dateOfBirth: _dateOfBirth,
          nationality: _nationalityController.text,
          countryOfResidence: _residenceController.text,
          maritalStatus: _maritalStatus,
          yearsOfExperience: int.tryParse(_experienceController.text),
          highestQualification: _highestQualification,
        );

    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackBar.show(
      context,
      emailChanged ? 'Profile updated. Check your new email address to confirm the change.' : 'Profile updated',
    );
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      pageTitle: 'Edit profile',
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
          Text('Edit profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'These details help refine your eligibility assessment and the '
            'soft-landing recommendations we surface for you.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          const SectionTitle(
            label: 'Contact details',
            subtitle: 'How we reach you',
            color: AppColors.gold,
          ),
          const SizedBox(height: 20),
          FloatingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: _decoration('Full name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: _decoration('Email'),
                ),
                const SizedBox(height: 16),
                PhoneCountryCodeField(
                  dialCode: _dialCode,
                  onDialCodeChanged: (code) => setState(() => _dialCode = code),
                  numberController: _phoneController,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const SectionTitle(
            label: 'Eligibility profile',
            subtitle: 'Used to refine your gap analysis and points estimate',
            color: AppColors.teal,
          ),
          const SizedBox(height: 20),
          FloatingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _pickDateOfBirth,
                  child: InputDecorator(
                    decoration: _decoration('Date of birth'),
                    child: Text(
                      _dateOfBirth == null
                          ? 'Select date of birth'
                          : '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _dateOfBirth == null ? AppColors.textMuted : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AutocompleteTextField(
                  label: 'Nationality',
                  controller: _nationalityController,
                  options: worldCountries,
                ),
                const SizedBox(height: 16),
                AutocompleteTextField(
                  label: 'Current country of residence',
                  controller: _residenceController,
                  options: worldCountries,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _maritalStatus,
                  decoration: _decoration('Marital status'),
                  dropdownColor: AppColors.surfaceCardHover,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  icon: const Icon(Icons.expand_more, color: AppColors.textMuted),
                  items: maritalStatusOptions
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (value) => setState(() => _maritalStatus = value ?? _maritalStatus),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: _decoration('Years of experience in your occupation'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _highestQualification,
                  decoration: _decoration('Highest qualification'),
                  dropdownColor: AppColors.surfaceCardHover,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  icon: const Icon(Icons.expand_more, color: AppColors.textMuted),
                  items: highestQualificationOptions
                      .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _highestQualification = value ?? _highestQualification),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _saving ? null : () => context.go('/'),
                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.backgroundDeep,
                  disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.backgroundDeep),
                      )
                    : const Text(
                        'Save changes',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

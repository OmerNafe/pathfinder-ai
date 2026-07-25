import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/avatar_upload_service.dart';
import '../services/supabase_service.dart';

const maritalStatusOptions = [
  'Single',
  'Married',
  'De facto / Partner',
  'Divorced',
  'Widowed',
];

const highestQualificationOptions = [
  'Diploma',
  "Bachelor's Degree",
  "Master's Degree",
  'Doctorate (PhD)',
  'Professional Certification',
];

class ProfileData {
  const ProfileData({
    required this.fullName,
    required this.email,
    required this.phone,
    this.dateOfBirth,
    required this.nationality,
    required this.countryOfResidence,
    required this.maritalStatus,
    this.yearsOfExperience,
    required this.highestQualification,
    this.avatarBytes,
    this.avatarUrl,
  });

  final String fullName;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;
  final String nationality;
  final String countryOfResidence;
  final String maritalStatus;
  final int? yearsOfExperience;
  final String highestQualification;

  /// An just-picked image, shown immediately while the real upload is in
  /// flight — not itself persisted. [avatarUrl] is the real, saved photo.
  final Uint8List? avatarBytes;
  final String? avatarUrl;

  ProfileData copyWith({
    String? fullName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? nationality,
    String? countryOfResidence,
    String? maritalStatus,
    int? yearsOfExperience,
    String? highestQualification,
    Uint8List? avatarBytes,
    String? avatarUrl,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      countryOfResidence: countryOfResidence ?? this.countryOfResidence,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      highestQualification: highestQualification ?? this.highestQualification,
      avatarBytes: avatarBytes ?? this.avatarBytes,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

/// Same pattern as PathwayNotifier: synchronous with background
/// hydrate/persist. Previously this returned fixed placeholder data
/// ("Applicant Name", "Qatar") for every signed-in user and never saved
/// edits — real per-user data now, mirroring pathway_state.dart.
class ProfileNotifier extends Notifier<ProfileData> {
  @override
  ProfileData build() {
    _hydrate();
    return ProfileData(
      fullName: '',
      email: AuthService.currentUser?.email ?? '',
      phone: '',
      nationality: '',
      countryOfResidence: '',
      maritalStatus: maritalStatusOptions.first,
      highestQualification: highestQualificationOptions.first,
    );
  }

  Future<void> _hydrate() async {
    if (!SupabaseService.isReady) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      final row = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return;
      final dobRaw = row['date_of_birth'] as String?;
      state = state.copyWith(
        fullName: row['full_name'] as String? ?? '',
        phone: row['phone'] as String? ?? '',
        dateOfBirth: dobRaw != null ? DateTime.tryParse(dobRaw) : null,
        nationality: row['nationality'] as String? ?? '',
        countryOfResidence: row['country_of_residence'] as String? ?? '',
        maritalStatus: row['marital_status'] as String? ?? maritalStatusOptions.first,
        yearsOfExperience: row['years_of_experience'] as int?,
        highestQualification: row['highest_qualification'] as String? ?? highestQualificationOptions.first,
        avatarUrl: row['avatar_url'] as String?,
      );
    } catch (_) {
      // Stay on defaults — see class doc.
    }
  }

  void updateDetails({
    required String fullName,
    required String email,
    required String phone,
    required DateTime? dateOfBirth,
    required String nationality,
    required String countryOfResidence,
    required String maritalStatus,
    required int? yearsOfExperience,
    required String highestQualification,
  }) {
    state = state.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      dateOfBirth: dateOfBirth,
      nationality: nationality,
      countryOfResidence: countryOfResidence,
      maritalStatus: maritalStatus,
      yearsOfExperience: yearsOfExperience,
      highestQualification: highestQualification,
    );
    _persist();
  }

  Future<void> _persist() async {
    if (!SupabaseService.isReady) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      await SupabaseService.client.from('profiles').update({
        'full_name': state.fullName,
        'phone': state.phone,
        'date_of_birth': state.dateOfBirth?.toIso8601String().split('T').first,
        'nationality': state.nationality,
        'country_of_residence': state.countryOfResidence,
        'marital_status': state.maritalStatus,
        'years_of_experience': state.yearsOfExperience,
        'highest_qualification': state.highestQualification,
      }).eq('id', userId);
    } catch (_) {
      // Optimistic local state stands even if the write failed — see class doc.
    }
  }

  /// Shows [bytes] immediately (optimistic preview), then uploads for
  /// real — on success the persisted avatarUrl takes over as the source
  /// of truth; on failure the exception propagates so the screen can tell
  /// the applicant it didn't actually save, rather than silently keeping
  /// a preview that looks saved but isn't.
  Future<void> updateAvatar(Uint8List bytes, {required String fileExt}) async {
    state = state.copyWith(avatarBytes: bytes);
    final url = await AvatarUploadService.upload(bytes: bytes, fileExt: fileExt);
    state = state.copyWith(avatarUrl: url);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileData>(ProfileNotifier.new);

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final Uint8List? avatarBytes;

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
    );
  }
}

class ProfileNotifier extends Notifier<ProfileData> {
  @override
  ProfileData build() {
    return const ProfileData(
      fullName: 'Applicant Name',
      email: 'you@example.com',
      phone: '',
      nationality: '',
      countryOfResidence: 'Qatar',
      maritalStatus: 'Single',
      highestQualification: "Bachelor's Degree",
    );
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
  }

  void updateAvatar(Uint8List bytes) {
    state = state.copyWith(avatarBytes: bytes);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileData>(ProfileNotifier.new);

import 'dart:math';

import '../data/sample_dashboard_data.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../state/pathway_state.dart';
import '../state/pathway_tasks.dart';

class CertificateShareException implements Exception {
  const CertificateShareException(this.message);
  final String message;
  @override
  String toString() => message;
}

const _tokenAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';

String _generateToken() {
  final random = Random.secure();
  return List.generate(22, (_) => _tokenAlphabet[random.nextInt(_tokenAlphabet.length)]).join();
}

/// Publishing is an explicit, one-shot snapshot of real current progress —
/// not a live feed a stranger could poll. Re-publishing (calling this
/// again later) overwrites the same link with fresh data rather than
/// minting a new one, so a previously shared link keeps working and just
/// shows the latest state.
class CertificateShareService {
  CertificateShareService._();

  static Future<String> publish({
    required PathwayData pathway,
    required List<PathwayTask> requirements,
  }) async {
    if (!SupabaseService.isReady) {
      throw const CertificateShareException(
        "The backend isn't connected yet, so there's nowhere to publish a real link to.",
      );
    }
    final userId = AuthService.currentUser?.id;
    if (userId == null) {
      throw const CertificateShareException('Sign in to publish a shareable certificate link.');
    }

    final client = SupabaseService.client;
    final existing =
        await client.from('pathways').select('share_token').eq('user_id', userId).maybeSingle();
    final token = (existing?['share_token'] as String?) ?? _generateToken();

    final verifiedCount = requirements.where((r) => r.status == TaskStatus.verified).length;
    final snapshot = {
      'occupation': pathway.occupation,
      'targetCountry': pathway.targetCountry,
      'verifiedCount': verifiedCount,
      'totalCount': requirements.length,
      'requirements': [
        for (final r in requirements)
          {
            'title': r.title,
            'status': r.status.name,
            'statusNote': r.statusNote,
          },
      ],
    };

    try {
      await client.from('pathways').update({
        'share_token': token,
        'certificate_snapshot': snapshot,
        'certificate_published_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('user_id', userId);
    } catch (e) {
      throw const CertificateShareException('Could not publish your certificate right now — try again.');
    }

    return '${Uri.base.origin}/#/c/$token';
  }
}

class PublicCertificateSnapshot {
  const PublicCertificateSnapshot({
    required this.occupation,
    required this.targetCountry,
    required this.verifiedCount,
    required this.totalCount,
    required this.requirements,
    this.publishedAt,
  });

  final String occupation;
  final String targetCountry;
  final int verifiedCount;
  final int totalCount;
  final List<PublicRequirementSnapshot> requirements;
  final DateTime? publishedAt;

  factory PublicCertificateSnapshot.fromJson(Map<String, dynamic> json) {
    final snapshot = json['snapshot'] as Map<String, dynamic>;
    final publishedAtRaw = json['publishedAt'] as String?;
    return PublicCertificateSnapshot(
      occupation: snapshot['occupation'] as String,
      targetCountry: snapshot['targetCountry'] as String,
      verifiedCount: snapshot['verifiedCount'] as int,
      totalCount: snapshot['totalCount'] as int,
      requirements: [
        for (final r in (snapshot['requirements'] as List))
          PublicRequirementSnapshot.fromJson(r as Map<String, dynamic>),
      ],
      publishedAt: publishedAtRaw != null ? DateTime.tryParse(publishedAtRaw) : null,
    );
  }
}

class PublicRequirementSnapshot {
  const PublicRequirementSnapshot({required this.title, required this.status, this.statusNote});
  final String title;
  final String status;
  final String? statusNote;

  factory PublicRequirementSnapshot.fromJson(Map<String, dynamic> json) {
    return PublicRequirementSnapshot(
      title: json['title'] as String,
      status: json['status'] as String,
      statusNote: json['statusNote'] as String?,
    );
  }
}

/// Fetches a published certificate by its public share token — no auth,
/// reachable by anyone with the link. Returns null when the backend isn't
/// configured or the link doesn't resolve to anything (never throws for
/// those cases — the caller shows an honest "not found" state either way).
Future<PublicCertificateSnapshot?> fetchPublicCertificate(String token) async {
  if (!SupabaseService.isReady) return null;
  try {
    final response = await SupabaseService.client.functions.invoke(
      'get-public-certificate',
      queryParameters: {'token': token},
    );
    final data = response.data;
    if (data is! Map) return null;
    if (data['snapshot'] == null) return null;
    return PublicCertificateSnapshot.fromJson(Map<String, dynamic>.from(data));
  } catch (_) {
    return null;
  }
}

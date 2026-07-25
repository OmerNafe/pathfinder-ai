import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

class PushNotificationException implements Exception {
  const PushNotificationException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Requests browser notification permission, registers this device's FCM
/// token, and persists it so send-reminders (once an email/push provider
/// key exists) has somewhere real to deliver to. The VAPID key is a
/// public identifier by design (like the Firebase apiKey itself), safe to
/// ship in the client bundle via the same .env pattern as
/// SUPABASE_ANON_KEY.
class PushNotificationService {
  PushNotificationService._();

  static bool get isConfigured => (dotenv.env['FIREBASE_VAPID_KEY'] ?? '').isNotEmpty;

  static Future<void> requestAndRegister() async {
    if (!isConfigured) {
      throw const PushNotificationException("Push notifications aren't set up on this deployment yet.");
    }
    if (!SupabaseService.isReady) {
      throw const PushNotificationException("The backend isn't connected yet.");
    }
    final userId = AuthService.currentUser?.id;
    if (userId == null) {
      throw const PushNotificationException('Sign in to enable push notifications.');
    }

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!granted) {
        throw const PushNotificationException('Notification permission was not granted.');
      }

      final token = await messaging.getToken(vapidKey: dotenv.env['FIREBASE_VAPID_KEY']);
      if (token == null) {
        throw const PushNotificationException('Could not register this device for push notifications.');
      }

      await SupabaseService.client.from('push_tokens').upsert(
        {'user_id': userId, 'token': token},
        onConflict: 'user_id,token',
      );
    } on PushNotificationException {
      rethrow;
    } catch (e) {
      throw PushNotificationException('Could not enable push notifications: $e');
    }
  }
}

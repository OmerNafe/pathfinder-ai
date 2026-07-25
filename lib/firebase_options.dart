import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Real config for the `pathfinder-ai-app` Firebase project, pulled via
/// `firebase apps:sdkconfig`. Only `web` is filled in — this app only
/// targets web today; Android/iOS platform folders exist (see
/// android/, ios/) but aren't buildable in this environment yet, so
/// there's no real config for them to have.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'DefaultFirebaseOptions have only been configured for web so far.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDimO7fJxJCX0sRs1O6vaZF97KrSf8eflQ',
    appId: '1:966060920852:web:8ab99f7fef3c55e7735701',
    messagingSenderId: '966060920852',
    projectId: 'pathfinder-ai-app',
    authDomain: 'pathfinder-ai-app.firebaseapp.com',
    storageBucket: 'pathfinder-ai-app.firebasestorage.app',
    measurementId: 'G-QJ6JMR33GB',
  );
}

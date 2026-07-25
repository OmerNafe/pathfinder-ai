// Handles push notifications that arrive while the app isn't the active
// tab. Loaded automatically by firebase_messaging_web -- must live at this
// exact path (web/firebase-messaging-sw.js) and be a classic (non-module)
// script, per Firebase's own requirement for this file.
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');

// Same project config as lib/firebase_options.dart -- the API key here is
// a public client identifier by Firebase's own design, not a secret.
firebase.initializeApp({
  apiKey: 'AIzaSyDimO7fJxJCX0sRs1O6vaZF97KrSf8eflQ',
  appId: '1:966060920852:web:8ab99f7fef3c55e7735701',
  messagingSenderId: '966060920852',
  projectId: 'pathfinder-ai-app',
  authDomain: 'pathfinder-ai-app.firebaseapp.com',
  storageBucket: 'pathfinder-ai-app.firebasestorage.app',
});

firebase.messaging();

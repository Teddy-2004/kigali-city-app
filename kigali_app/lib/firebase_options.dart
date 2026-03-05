import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCYvDqDOrC5Z2gWKg1eSUFzptCkmLTN0sA',
    appId: '1:224569675581:android:ff960cbdb8c44a53ef7f54',
    messagingSenderId: '224569675581',
    projectId: 'kigali-city-b5b4c',
    storageBucket: 'kigali-city-b5b4c.firebasestorage.app',
  );
}
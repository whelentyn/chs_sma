// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB8uMv1vVaWJylk7mTJK0lGXebzvKw-6XI',
    appId: '1:703601281965:web:91a45a17d83224bdd8ef24',
    messagingSenderId: '703601281965',
    projectId: 'cooking-app-apvb',
    authDomain: 'cooking-app-apvb.firebaseapp.com',
    storageBucket: 'cooking-app-apvb.appspot.com',
    measurementId: 'G-C3H4TFFCW2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-bHJvBZjJwgmtbDhWBDjP__mHZBuAtb8',
    appId: '1:703601281965:android:3941793c03c060eed8ef24',
    messagingSenderId: '703601281965',
    projectId: 'cooking-app-apvb',
    storageBucket: 'cooking-app-apvb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAtFQOQKAoyGc-tWkCx11RLBDcKq_A2FHY',
    appId: '1:703601281965:ios:5cc82e7f8ea9740cd8ef24',
    messagingSenderId: '703601281965',
    projectId: 'cooking-app-apvb',
    storageBucket: 'cooking-app-apvb.appspot.com',
    iosBundleId: 'com.example.cookingApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAtFQOQKAoyGc-tWkCx11RLBDcKq_A2FHY',
    appId: '1:703601281965:ios:7fe3098ce0ea155fd8ef24',
    messagingSenderId: '703601281965',
    projectId: 'cooking-app-apvb',
    storageBucket: 'cooking-app-apvb.appspot.com',
    iosBundleId: 'com.example.cookingApp.RunnerTests',
  );
}

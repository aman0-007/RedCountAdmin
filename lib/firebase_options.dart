// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyCufSY3tcdjGg6DRH-ctBeeEKwwt27lszs',
    appId: '1:587619807474:web:5142d88bc6d7e76105e06b',
    messagingSenderId: '587619807474',
    projectId: 'liquidlove-8d454',
    authDomain: 'liquidlove-8d454.firebaseapp.com',
    databaseURL: 'https://liquidlove-8d454-default-rtdb.firebaseio.com',
    storageBucket: 'liquidlove-8d454.appspot.com',
    measurementId: 'G-05YXY9JBD6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJNlMj0eJJl8mWUmeJuibCK3vS92L3zjk',
    appId: '1:587619807474:android:9437c51deb8413a705e06b',
    messagingSenderId: '587619807474',
    projectId: 'liquidlove-8d454',
    databaseURL: 'https://liquidlove-8d454-default-rtdb.firebaseio.com',
    storageBucket: 'liquidlove-8d454.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCedROeQS28RTqoGCq7fE8jUEcroJqXO2I',
    appId: '1:587619807474:ios:78698b09ec86819305e06b',
    messagingSenderId: '587619807474',
    projectId: 'liquidlove-8d454',
    databaseURL: 'https://liquidlove-8d454-default-rtdb.firebaseio.com',
    storageBucket: 'liquidlove-8d454.appspot.com',
    androidClientId: '587619807474-1skjp3fts9eo9vaadu3aao89a74k7e1k.apps.googleusercontent.com',
    iosClientId: '587619807474-fben9lt8ageh3mpab83cnhjl6dctklnh.apps.googleusercontent.com',
    iosBundleId: 'com.example.redcountadmin',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCedROeQS28RTqoGCq7fE8jUEcroJqXO2I',
    appId: '1:587619807474:ios:78698b09ec86819305e06b',
    messagingSenderId: '587619807474',
    projectId: 'liquidlove-8d454',
    databaseURL: 'https://liquidlove-8d454-default-rtdb.firebaseio.com',
    storageBucket: 'liquidlove-8d454.appspot.com',
    androidClientId: '587619807474-1skjp3fts9eo9vaadu3aao89a74k7e1k.apps.googleusercontent.com',
    iosClientId: '587619807474-fben9lt8ageh3mpab83cnhjl6dctklnh.apps.googleusercontent.com',
    iosBundleId: 'com.example.redcountadmin',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCufSY3tcdjGg6DRH-ctBeeEKwwt27lszs',
    appId: '1:587619807474:web:2d15aee41dc9362b05e06b',
    messagingSenderId: '587619807474',
    projectId: 'liquidlove-8d454',
    authDomain: 'liquidlove-8d454.firebaseapp.com',
    databaseURL: 'https://liquidlove-8d454-default-rtdb.firebaseio.com',
    storageBucket: 'liquidlove-8d454.appspot.com',
    measurementId: 'G-P6B4ZC3Y62',
  );
}

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA2FsnLOrRcTCTTbiFk-4JxczNoF0DbJO4',
    appId: '1:292200430256:web:e2aa03a9095a5ae8bfd975',
    messagingSenderId: '292200430256',
    projectId: 'legancka-ffcbc',
    authDomain: 'legancka-ffcbc.firebaseapp.com',
    storageBucket: 'legancka-ffcbc.appspot.com',
    measurementId: 'G-CS3WF1Q0VW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwp3ZWBScjYX0ly7KE42q06Jh_b2ensBQ',
    appId: '1:292200430256:android:03cfc29aca197a18bfd975',
    messagingSenderId: '292200430256',
    projectId: 'legancka-ffcbc',
    storageBucket: 'legancka-ffcbc.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_bvdbSo-M6waYZp889ToNATJ0lzfdI9Q',
    appId: '1:292200430256:ios:5b9e6c8bed79dc47bfd975',
    messagingSenderId: '292200430256',
    projectId: 'legancka-ffcbc',
    storageBucket: 'legancka-ffcbc.appspot.com',
    iosClientId: '292200430256-sqafoh70l1550ikvtoh11abe916ptb91.apps.googleusercontent.com',
    iosBundleId: 'com.zam.rks',
  );
}
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
    apiKey: 'AIzaSyBkUVsOscmMqNH3CAJ6GNIEJ7q-m7BFXfo',
    appId: '1:292365218851:web:48587cc89085b54d00ad96',
    messagingSenderId: '292365218851',
    projectId: 'task-synchro',
    authDomain: 'task-synchro.firebaseapp.com',
    storageBucket: 'task-synchro.appspot.com',
    measurementId: 'G-P6ZZ1P0XTM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAba7D2zXbTfj-vzEPIJXm4a5bpEOwI__c',
    appId: '1:292365218851:android:68a1996d91b26bdb00ad96',
    messagingSenderId: '292365218851',
    projectId: 'task-synchro',
    storageBucket: 'task-synchro.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD2V5qRd1kKLaflvubGoDiUHtfY20nK_H4',
    appId: '1:292365218851:ios:ce7674934249b7a200ad96',
    messagingSenderId: '292365218851',
    projectId: 'task-synchro',
    storageBucket: 'task-synchro.appspot.com',
    iosBundleId: 'com.example.taskSynchro',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD2V5qRd1kKLaflvubGoDiUHtfY20nK_H4',
    appId: '1:292365218851:ios:ce7674934249b7a200ad96',
    messagingSenderId: '292365218851',
    projectId: 'task-synchro',
    storageBucket: 'task-synchro.appspot.com',
    iosBundleId: 'com.example.taskSynchro',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBkUVsOscmMqNH3CAJ6GNIEJ7q-m7BFXfo',
    appId: '1:292365218851:web:3e963201daecdf5d00ad96',
    messagingSenderId: '292365218851',
    projectId: 'task-synchro',
    authDomain: 'task-synchro.firebaseapp.com',
    storageBucket: 'task-synchro.appspot.com',
    measurementId: 'G-YGNVE3ZXZY',
  );
}

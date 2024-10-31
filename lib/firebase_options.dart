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
    apiKey: 'AIzaSyBbtm80bT7bdaFt4zsyWNpl4_QMPDeUMQw',
    appId: '1:355221778759:web:8eed70f08b1605593bdc62',
    messagingSenderId: '355221778759',
    projectId: 'conteo-votaciones',
    authDomain: 'conteo-votaciones.firebaseapp.com',
    databaseURL: 'https://conteo-votaciones-default-rtdb.firebaseio.com',
    storageBucket: 'conteo-votaciones.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9_eoQ8xe4LpeQ74k37zdLoOtLCGLCi30',
    appId: '1:355221778759:android:b6bdd793ad85d72e3bdc62',
    messagingSenderId: '355221778759',
    projectId: 'conteo-votaciones',
    databaseURL: 'https://conteo-votaciones-default-rtdb.firebaseio.com',
    storageBucket: 'conteo-votaciones.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCXTz6HLGx8XgbMxmwmiT_xlvzMd8MiwNc',
    appId: '1:355221778759:ios:b24027b05df7ec6e3bdc62',
    messagingSenderId: '355221778759',
    projectId: 'conteo-votaciones',
    databaseURL: 'https://conteo-votaciones-default-rtdb.firebaseio.com',
    storageBucket: 'conteo-votaciones.appspot.com',
    iosBundleId: 'com.ando.devs.conteoVotaciones',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCXTz6HLGx8XgbMxmwmiT_xlvzMd8MiwNc',
    appId: '1:355221778759:ios:b24027b05df7ec6e3bdc62',
    messagingSenderId: '355221778759',
    projectId: 'conteo-votaciones',
    databaseURL: 'https://conteo-votaciones-default-rtdb.firebaseio.com',
    storageBucket: 'conteo-votaciones.appspot.com',
    iosBundleId: 'com.ando.devs.conteoVotaciones',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBbtm80bT7bdaFt4zsyWNpl4_QMPDeUMQw',
    appId: '1:355221778759:web:a8b3528083ae92063bdc62',
    messagingSenderId: '355221778759',
    projectId: 'conteo-votaciones',
    authDomain: 'conteo-votaciones.firebaseapp.com',
    databaseURL: 'https://conteo-votaciones-default-rtdb.firebaseio.com',
    storageBucket: 'conteo-votaciones.appspot.com',
  );
}
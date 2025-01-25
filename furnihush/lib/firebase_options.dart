import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not supported');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:XXXXXXXXXXXX:android:XXXXXXXXXXXXXXXXXXXXXXXX',
    messagingSenderId: 'XXXXXXXXXXXX',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:XXXXXXXXXXXX:ios:XXXXXXXXXXXXXXXXXXXXXXXX',
    messagingSenderId: 'XXXXXXXXXXXX',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosClientId:
        'XXXXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com',
    iosBundleId: 'com.example.furnihush',
  );
}

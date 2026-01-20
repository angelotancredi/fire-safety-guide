import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyBCfcuXTMuQ9Scqr0Xyzg426Y1Ju1Q2tfw",
      authDomain: "fire-safety-lens.firebaseapp.com",
      projectId: "fire-safety-lens",
      storageBucket: "fire-safety-lens.firebasestorage.app",
      messagingSenderId: "796667500943",
      appId: "1:796667500943:web:b84f24af5b7c0a66b413fa",
    );
  }
}

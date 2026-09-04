import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase inicializado correctamente.', name: 'FirebaseInit');
  } catch (e) {
    developer.log(
      'Aviso de conexión Firebase: ${e.toString()}',
      name: 'FirebaseInit',
      error: e,
    );
  }

  runApp(
    const ProviderScope(
      child: AnaAriasStudioApp(),
    ),
  );
}

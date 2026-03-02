import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fitsy/app/app.dart';
import 'package:fitsy/core/di/injection.dart';
import 'package:fitsy/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  configureDependencies();
  runApp(const FitsyApp());
}

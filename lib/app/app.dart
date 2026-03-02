import 'package:flutter/material.dart';
import 'package:fitsy/app/routes.dart';
import 'package:fitsy/app/theme.dart';

class FitsyApp extends StatelessWidget {
  const FitsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fitsy',
      theme: FitsyTheme.darkTheme,
      routerConfig: routerConfig,
      debugShowCheckedModeBanner: false,
    );
  }
}

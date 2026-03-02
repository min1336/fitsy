import 'package:flutter/material.dart';

void main() {
  runApp(const FitsyApp());
}

class FitsyApp extends StatelessWidget {
  const FitsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitsy',
      theme: ThemeData.dark(useMaterial3: true),
      home: const Scaffold(
        body: Center(
          child: Text('Fitsy'),
        ),
      ),
    );
  }
}

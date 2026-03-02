import 'package:flutter/material.dart';

class OutfitPage extends StatelessWidget {
  const OutfitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 코디')),
      body: const Center(
        child: Text('코디 추천이 여기에 표시됩니다'),
      ),
    );
  }
}

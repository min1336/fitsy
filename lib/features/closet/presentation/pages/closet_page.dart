import 'package:flutter/material.dart';

class ClosetPage extends StatelessWidget {
  const ClosetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 옷장')),
      body: const Center(
        child: Text('옷장 목록이 여기에 표시됩니다'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 옷 추가 화면으로 이동
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

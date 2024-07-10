import 'package:flutter/material.dart';

class WalkPage extends StatelessWidget {
  const WalkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대략 산책 페이지'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("산책 기능 넣기."),
          ],
        ),
      ),
    );
  }
}
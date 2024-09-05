import 'package:flutter/material.dart';

// 로딩 화면을 보여주는 페이지, StatelessWidget을 상속받음
class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 앱바에 '매칭 진행 중...'이라는 제목 표시
      appBar: AppBar(
        title: const Text('매칭 진행 중...'),
      ),
      body: const Center(
        // 화면의 중앙에 위젯 배치
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 위젯을 세로 방향으로 중앙에 배치
          children: <Widget>[
            // 로딩 중임을 나타내는 CircularProgressIndicator (회전하는 원)
            CircularProgressIndicator(),
            SizedBox(height: 20), // 로딩 아이콘과 텍스트 사이에 간격
            // 안내 텍스트
            Text("주인을 찾는 중입니다. "),
            Text("잠시만 기다려 주세요."),
          ],
        ),
      ),
    );
  }
}

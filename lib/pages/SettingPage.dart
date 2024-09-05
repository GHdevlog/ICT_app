import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'SignInPage.dart';

// 설정 페이지를 위한 StatelessWidget 클래스
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 로그인된 사용자 정보 가져오기
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        // 상단 앱바에 '설정'이라는 제목 표시
        title: const Text('설정'),
      ),
      body: Padding(
        // 페이지에 기본적인 패딩을 추가
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 사용자의 이메일을 표시. 없으면 '알 수 없음'으로 표시
            Text(
              '계정 이름: ${user?.email ?? '알 수 없음'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20), // 위젯 간의 간격 설정
            // 로그아웃 버튼
            ElevatedButton(
              onPressed: () async {
                // Firebase 인증에서 로그아웃
                await FirebaseAuth.instance.signOut();
                // 로그아웃 후 로그인 페이지로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
              child: const Text('로그아웃'),
            ),
            const SizedBox(height: 10), // 위젯 간의 간격 설정
            // 회원 탈퇴 버튼
            ElevatedButton(
              onPressed: () async {
                // 사용자 삭제 로직
                try {
                  await user?.delete(); // 현재 사용자 삭제
                  // 탈퇴 후 로그인 페이지로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                } catch (e) {
                  print('회원 탈퇴 오류: $e');
                  // 오류가 발생했을 때 추가적인 처리 필요 (예: 다이얼로그로 오류 메시지 표시)
                }
              },
              child: const Text('회원 탈퇴'),
            ),
          ],
        ),
      ),
    );
  }
}

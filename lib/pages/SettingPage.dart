import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'SignInPage.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '계정 이름: ${user?.email ?? '알 수 없음'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
              child: const Text('로그아웃'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // 사용자 삭제
                try {
                  await user?.delete();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                  );
                } catch (e) {
                  print('회원 탈퇴 오류: $e');
                  // 오류 처리 코드 추가
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

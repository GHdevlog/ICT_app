import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ict_face_recog/pages/SignInPage.dart';

// main 함수: Flutter 앱의 시작 지점
void main() async {
  // Flutter 위젯 바인딩 초기화, 비동기 작업을 위해 필요
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase 초기화, 앱 실행 전 Firebase 관련 설정을 완료
  await Firebase.initializeApp();
  // Flutter 앱 실행
  runApp(const MyApp());
}

// MyApp 클래스: 앱의 최상위 위젯으로 MaterialApp을 사용
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo', // 앱의 제목
      theme: ThemeData(
        primarySwatch: Colors.blue, // 기본 테마 색상 설정
      ),
      home: const SignInPage(), // 앱이 처음 시작될 때 표시할 페이지 (로그인 페이지)
    );
  }
}

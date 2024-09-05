import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'SignUpPage.dart';

// SignInPage 위젯 클래스, StatefulWidget을 사용하여 상태 변화에 대응
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

// SignInPage의 상태 클래스
class _SignInPageState extends State<SignInPage> {
  // 이메일과 비밀번호 입력을 위한 컨트롤러
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance; // Firebase 인증 인스턴스
  String _statusMessage = ''; // 로그인 상태 메시지

  // 로그인 처리 함수
  Future<void> _signIn() async {
    try {
      // Firebase Auth로 이메일과 비밀번호를 통해 로그인 시도
      final UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return; // 현재 위젯이 화면에 렌더링되어 있는지 확인

      setState(() {
        _statusMessage = '로그인 성공!';
      });

      // 로그인 성공 시 홈 페이지로 이동하며 기존 네비게이션 스택을 모두 제거
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      // 오류가 발생하면 오류 메시지를 표시
      setState(() {
        _statusMessage = e.message ?? '로그인 실패';
      });
    }
  }

  // 회원가입 페이지로 이동하는 함수
  void _navigateToSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('로그인'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 이메일 입력 필드
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      hintText: "example@example.com",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              // 비밀번호 입력 필드
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      hintText: "Enter your password",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true, // 비밀번호 입력 시 텍스트를 가림
                  ),
                ),
              ),
              // 로그인 버튼
              ElevatedButton(
                onPressed: _signIn, // 로그인 함수 호출
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text("Sign In"),
              ),
              const SizedBox(height: 20),
              // 로그인 상태 메시지 표시
              Text(
                _statusMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // 회원가입 페이지로 이동하는 버튼
              TextButton(
                onPressed: _navigateToSignUpPage, // 회원가입 페이지 이동 함수 호출
                child: const Text("계정이 없으신가요? 회원가입"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

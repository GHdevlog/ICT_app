import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'SignInPage.dart'; // 로그인 페이지 import

// 회원가입 페이지 StatefulWidget 클래스
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

// 회원가입 페이지 상태 클래스
class _SignUpPageState extends State<SignUpPage> {
  // 이메일, 패스워드, 패스워드 확인을 위한 텍스트 컨트롤러
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance; // Firebase 인증 인스턴스
  String _statusMessage = ''; // 상태 메시지

  // 회원가입 처리 함수
  Future<void> _signUp() async {
    // 패스워드와 패스워드 확인이 일치하지 않을 경우
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _statusMessage = '패스워드가 일치하지 않습니다.';
      });
      return;
    }

    try {
      // Firebase Auth로 이메일과 패스워드를 통해 회원가입 시도
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // 이메일 인증이 필요할 경우 인증 메일을 전송
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        setState(() {
          _statusMessage = '인증 이메일이 발송되었습니다. 이메일을 확인해주세요.';
        });

        // 회원가입 성공 후 로그인 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 오류가 발생할 경우 오류 메시지 표시
      setState(() {
        _statusMessage = e.message ?? '회원가입 실패';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          // 상단 앱바에 '회원가입'이라는 제목 표시
          title: const Text('회원가입'),
          // 뒤로가기 버튼
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        // 페이지 내용
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
                    obscureText: true, // 비밀번호 입력 시 텍스트를 숨김
                  ),
                ),
              ),
              // 비밀번호 확인 입력 필드
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: "Confirm Password",
                      hintText: "Re-enter your password",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ),
              ),
              // 회원가입 버튼
              ElevatedButton(
                onPressed: _signUp, // 회원가입 처리 함수 호출
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text("Sign Up"),
              ),
              const SizedBox(height: 20),
              // 상태 메시지 표시 (오류 또는 성공 메시지)
              Text(
                _statusMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

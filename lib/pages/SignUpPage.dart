import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'SignInPage.dart'; // 로그인 페이지를 import

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String _statusMessage = '';

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _statusMessage = '패스워드가 일치하지 않습니다.';
      });
      return;
    }

    try {
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        setState(() {
          _statusMessage = '인증 이메일이 발송되었습니다. 이메일을 확인해주세요.';
        });

        // 회원가입 성공 시 로그인 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
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
          title: const Text('회원가입'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
                    obscureText: true,
                  ),
                ),
              ),
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
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text("Sign Up"),
              ),
              const SizedBox(height: 20),
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

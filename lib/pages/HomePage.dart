import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'DiaryPage.dart';
import 'FindLostPetPage.dart';
import 'RegisterPetPage.dart';
import 'SignInPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  User? _user;

  static const List<Widget> _pages = <Widget>[
    RegisterPetPage(),
    FindLostPetPage(),
    DiaryPage(),
    // 추가할 다른 페이지도 여기에 추가
  ];

  @override
  void initState() {
    super.initState();
    // Firebase Auth 상태 변화 감지
    _authStateListener();
  }

  void _authStateListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
      // 디버깅 메시지 출력
      if (user == null) {
        print('사용자가 로그아웃했습니다.');
      } else {
        print('사용자가 로그인했습니다: ${user.email}');
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToSignInPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    print('사용자가 로그아웃했습니다.');
    // 로그아웃 후 로그인 페이지로 이동하면서 뒤로가기 스택 비우기
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmileCompanion'),
        actions: [
          _user == null
              ? TextButton.icon(
            icon: const Icon(Icons.person, color: Colors.black),
            label: const Text(
              '로그인',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: _navigateToSignInPage,
          )
              : TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.black),
            label: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: '반려동물 등록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '실종 반려동물',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: '다이어리',
          ),
          // 추가할 다른 항목도 여기에 추가
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

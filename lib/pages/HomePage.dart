import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'DiaryPage.dart';
import 'FindLostPetPage.dart';
import 'RegisterPetPage.dart';
import 'SignInPage.dart';
import 'SettingPage.dart';

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

  void _navigateToSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmileCompanion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettingsPage,
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

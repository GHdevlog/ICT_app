import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'DiaryPage.dart';
import 'FindLostPetPage.dart';
import 'PetRegisterPage.dart';
import 'SettingPage.dart';
import 'SignInPage.dart';
import 'WalkPage.dart';

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
    WalkPage(),
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
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmileCompanion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
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
        type: BottomNavigationBarType.fixed,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: '산책',
          ),
          // 추가할 다른 항목도 여기에 추가
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
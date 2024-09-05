import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'DiaryPage.dart';
import 'FindLostPetPage.dart';
import 'PetRegisterPage.dart';
import 'SettingPage.dart';
import 'SignInPage.dart';
import 'WalkPage.dart';

// HomePage 위젯 클래스 선언. StatefulWidget을 사용하여 상태 변화에 대응할 수 있게 설계
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

// HomePage 상태 클래스
class _HomePageState extends State<HomePage> {
  // 현재 선택된 인덱스를 저장하는 변수. 기본값은 0
  int _selectedIndex = 0;

  // Firebase 인증으로부터 가져온 현재 사용자를 저장하는 변수
  User? _user;

  // 앱에서 사용할 각 페이지들을 리스트로 저장. 인덱스에 따라 다른 페이지를 보여줌
  static const List<Widget> _pages = <Widget>[
    RegisterPetPage(), // 반려동물 등록 페이지
    FindLostPetPage(), // 실종 반려동물 찾기 페이지
    DiaryPage(),       // 반려동물 일기 페이지
    WalkPage(),        // 산책 기록 페이지
    // 추가할 다른 페이지도 여기에 추가 가능
  ];

  @override
  void initState() {
    super.initState();
    // Firebase Auth의 인증 상태 변화를 감지하고 상태를 업데이트하는 메소드 호출
    _authStateListener();
  }

  // Firebase Auth 상태 변화 감지 메소드
  void _authStateListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        // 사용자가 로그인되면 _user 변수에 저장, 로그아웃되면 null이 됨
        _user = user;
      });
      // 사용자 상태에 따라 로그 출력
      if (user == null) {
        print('사용자가 로그아웃했습니다.');
      } else {
        print('사용자가 로그인했습니다: ${user.email}');
      }
    });
  }

  // 하단 네비게이션 바의 아이템이 선택되었을 때 호출되는 메소드
  void _onItemTapped(int index) {
    setState(() {
      // 선택된 인덱스를 업데이트하여 해당 페이지를 보여줌
      _selectedIndex = index;
    });
  }

  // 설정 페이지로 이동하는 메소드
  void _navigateToSettingsPage() {
    Navigator.push(
      context,
      // SettingsPage로 이동하는 네비게이션을 설정
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  // Firebase 인증에서 로그아웃을 처리하는 메소드
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // 로그아웃 후 SignInPage로 리디렉션
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 상단 앱바에 표시할 제목
        title: const Text('SmileCompanion'),
        actions: [
          // 로그아웃 버튼을 테두리가 있는 OutlinedButton으로 변경
          OutlinedButton(
            onPressed: _signOut,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF9A9A9A)),  // 테두리 색상 설정
            ),
            child: const Text('로그아웃'),
          ),
          // 설정 페이지로 이동하는 버튼
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettingsPage,
          ),
        ],
      ),
      // 선택된 페이지를 화면에 표시
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      // 하단 네비게이션 바 설정
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // 네비게이션 바의 각 아이템 설정
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
          // 추가할 다른 항목도 여기에 추가 가능
        ],
        // 현재 선택된 인덱스를 표시
        currentIndex: _selectedIndex,
        // 선택된 아이템 색상
        selectedItemColor: const Color(0xFFFF6C05),
        // 선택되지 않은 아이템 색상
        unselectedItemColor: const Color(0xFFFF964A),
        // 배경색 설정
        backgroundColor: const Color(0xFFFFFAE6),
        // 아이템이 눌렸을 때 _onItemTapped 메소드 호출
        onTap: _onItemTapped,
      ),
    );
  }
}

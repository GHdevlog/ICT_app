import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'DiaryEntryDialog.dart'; // 일기 작성 다이얼로그를 불러오는 파일
import 'DiaryContentDialog.dart'; // 일기 내용을 표시하는 다이얼로그를 불러오는 파일
import '../models/event_marker.dart'; // 이벤트 마커를 위한 파일

// 다이어리 페이지를 위한 StatefulWidget
class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

// 다이어리 페이지 상태 관리 클래스
class _DiaryPageState extends State<DiaryPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance; // Firestore 인스턴스
  final FirebaseAuth auth = FirebaseAuth.instance; // Firebase 인증 인스턴스
  DateTime _selectedDate = DateTime.now(); // 사용자가 선택한 날짜
  DateTime _focusedDate = DateTime.now(); // 현재 화면에 표시되는 날짜
  String? userId; // 사용자 ID 저장
  Map<DateTime, List<dynamic>> _events = {}; // 날짜별 이벤트 저장
  final DateTime _firstDay = DateTime.utc(2000, 1, 1); // 캘린더의 첫 날
  final DateTime _lastDay = DateTime.utc(2100, 12, 31); // 캘린더의 마지막 날

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(); // 날짜 형식을 초기화
    _getCurrentUser(); // 현재 로그인된 사용자 정보 가져오기
  }

  // 현재 사용자를 가져오는 비동기 함수
  Future<void> _getCurrentUser() async {
    final User? user = auth.currentUser; // Firebase에서 현재 로그인된 사용자 정보 가져오기
    if (user != null) {
      setState(() {
        userId = user.uid; // 사용자 ID 저장
      });
      print("Current user ID: $userId"); // 디버깅 메시지
      _loadDiaryEntries(_focusedDate); // 선택된 날짜의 일기 데이터를 로드
    } else {
      print("No user is currently signed in."); // 로그인된 사용자가 없을 경우
    }
  }

  // 특정 달의 일기 데이터를 Firestore에서 가져오는 함수
  Future<void> _loadDiaryEntries(DateTime focusedDate) async {
    if (userId != null) {
      final startOfMonth = DateTime(focusedDate.year, focusedDate.month, 1); // 해당 달의 시작일
      final endOfMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0); // 해당 달의 마지막일

      // Firestore에서 해당 달의 일기 데이터를 가져옴
      db.collection('users').doc(userId).collection('diaries')
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get().then((snapshot) {
        setState(() {
          // 각 날짜별로 일기 제목을 저장
          _events = {
            for (var doc in snapshot.docs)
              DateTime((doc['date'] as Timestamp).toDate().year, (doc['date'] as Timestamp).toDate().month, (doc['date'] as Timestamp).toDate().day):
              List.generate(1, (index) => doc['title']),
          };
        });
      }).catchError((e) {
        print("Failed to load diary entries: $e"); // 오류 발생 시 출력
      });
    }
  }

  // Firestore에서 일기 데이터를 삭제하는 함수
  Future<void> _deleteDiaryEntry(String id) async {
    if (userId != null) {
      try {
        await db.collection('users').doc(userId).collection('diaries').doc(id).delete(); // 해당 일기 삭제
        print("Diary entry deleted for user ID: $userId"); // 삭제 성공 메시지
        _loadDiaryEntries(_focusedDate); // 삭제 후 일기 데이터 다시 로드
      } catch (e) {
        print("Failed to delete diary entry: $e"); // 오류 발생 시 출력
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('다이어리'), // 앱바 제목
      ),
      body: Column(
        children: [
          // 캘린더 위젯
          TableCalendar(
            locale: 'ko_KR', // 한국어 설정
            firstDay: _firstDay, // 첫 날짜 설정
            lastDay: _lastDay, // 마지막 날짜 설정
            focusedDay: _focusedDate, // 현재 포커스된 날짜
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day); // 선택된 날짜와 같은지 확인
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay; // 선택된 날짜 저장
                _focusedDate = focusedDay; // 포커스된 날짜 저장
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDate = focusedDay; // 페이지 변경 시 포커스된 날짜 변경
                _loadDiaryEntries(_focusedDate); // 페이지가 변경될 때마다 일기 데이터 다시 로드
              });
            },
            eventLoader: (day) {
              DateTime dayWithoutTime = DateTime(day.year, day.month, day.day); // 시간을 제외한 날짜만 추출
              return _events[dayWithoutTime] ?? []; // 해당 날짜의 이벤트 반환
            },
            // 캘린더 스타일 설정
            daysOfWeekHeight: 20 * MediaQuery.of(context).textScaleFactor,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, // 형식 버튼 숨기기
              titleCentered: true, // 제목 중앙 정렬
            ),
            calendarStyle: const CalendarStyle(
              cellMargin: EdgeInsets.symmetric(vertical: 8.0), // 셀 여백 설정
              todayDecoration: BoxDecoration(
                color: Colors.blue, // 오늘 날짜 배경색
                shape: BoxShape.circle, // 원형 모양
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange, // 선택된 날짜 배경색
                shape: BoxShape.circle, // 원형 모양
              ),
              defaultTextStyle: TextStyle(
                fontSize: 18.0, // 기본 날짜 텍스트 크기
              ),
              outsideTextStyle: TextStyle(
                fontSize: 16.0, // 다른 달의 날짜 텍스트 크기
                color: Colors.grey,
              ),
              tableBorder: TableBorder(
                top: BorderSide(color: Colors.black), // 테이블 상단 경계선
                right: BorderSide(color: Colors.black12),
                bottom: BorderSide(color: Colors.black),
                left: BorderSide(color: Colors.black12),
                horizontalInside: BorderSide(color: Colors.black12),
                verticalInside: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.zero,
              ),
            ),
            // 날짜에 맞는 마커를 생성하는 빌더
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (day.weekday == DateTime.saturday) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.blue, fontSize: 18.0), // 토요일 텍스트 색상
                    ),
                  );
                } else if (day.weekday == DateTime.sunday) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.red, fontSize: 18.0), // 일요일 텍스트 색상
                    ),
                  );
                }
                return null;
              },
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 5,
                    right: 8,
                    child: buildEventsMarker(day, events), // 이벤트 마커 표시
                  );
                }
                return null;
              },
            ),
          ),
          // 선택된 날짜의 일기 목록 표시
          Expanded(
            child: userId == null
                ? const Center(child: CircularProgressIndicator()) // 사용자 ID가 없으면 로딩 표시
                : StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('users')
                  .doc(userId)
                  .collection('diaries')
                  .where('date', isGreaterThanOrEqualTo: DateTime(_focusedDate.year, _focusedDate.month, 1)) // 해당 달의 일기
                  .where('date', isLessThanOrEqualTo: DateTime(_focusedDate.year, _focusedDate.month + 1, 0))
                  .orderBy('date', descending: true) // 날짜 기준으로 내림차순 정렬
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator()); // 데이터가 없으면 로딩 표시
                }
                final documents = snapshot.data!.docs; // 가져온 일기 목록
                return ListView.builder(
                  itemCount: documents.length, // 목록 개수
                  itemBuilder: (context, index) {
                    final doc = documents[index]; // 개별 문서
                    return ListTile(
                      title: Text(doc['title']), // 일기 제목
                      subtitle: Text(doc['date'].toDate().toString()), // 일기 날짜
                      onTap: () => showDiaryContentDialog(context, doc['title'], doc['content']), // 일기 내용 표시
                      trailing: IconButton(
                        icon: const Icon(Icons.delete), // 삭제 아이콘
                        onPressed: () => _deleteDiaryEntry(doc.id), // 일기 삭제 함수 호출
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // 플로팅 액션 버튼을 눌러 새로운 일기 추가
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEntryDialog(context, _selectedDate, userId, db, _loadDiaryEntries), // 일기 추가 다이얼로그 호출
        child: const Icon(Icons.add), // 플로팅 버튼 아이콘
      ),
    );
  }
}

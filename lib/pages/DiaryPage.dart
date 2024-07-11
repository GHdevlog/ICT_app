import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  String? userId;
  Map<DateTime, List<dynamic>> _events = {};
  final DateTime _firstDay = DateTime.utc(2000, 1, 1);
  final DateTime _lastDay = DateTime.utc(2100, 12, 31);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      print("Current user ID: $userId");
      _loadDiaryEntries(_focusedDate);
    } else {
      print("No user is currently signed in.");
    }
  }

  Future<void> _loadDiaryEntries(DateTime focusedDate) async {
    if (userId != null) {
      final startOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
      final endOfMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0);

      db.collection('users').doc(userId).collection('diaries')
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get().then((snapshot) {
        setState(() {
          _events = {
            for (var doc in snapshot.docs)
              DateTime((doc['date'] as Timestamp).toDate().year, (doc['date'] as Timestamp).toDate().month, (doc['date'] as Timestamp).toDate().day):
              List.generate(1, (index) => doc['title']),
          };
        });
      }).catchError((e) {
        print("Failed to load diary entries: $e");
      });
    }
  }

  Future<void> _addDiaryEntry(String title, String content) async {
    if (title.isNotEmpty && content.isNotEmpty && userId != null) {
      try {
        await db.collection('users').doc(userId).collection('diaries').add({
          'title': title,
          'content': content,
          'date': _selectedDate,
          'createdAt': Timestamp.now(),
        });
        print("Diary entry added for user ID: $userId");
        _loadDiaryEntries(_focusedDate);
      } catch (e) {
        print("Failed to add diary entry: $e");
      }
    }
  }

  Future<void> _deleteDiaryEntry(String id) async {
    if (userId != null) {
      try {
        await db.collection('users').doc(userId).collection('diaries').doc(id).delete();
        print("Diary entry deleted for user ID: $userId");
        _loadDiaryEntries(_focusedDate);
      } catch (e) {
        print("Failed to delete diary entry: $e");
      }
    }
  }

  void _showAddEntryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController popupTitleController = TextEditingController();
        final TextEditingController popupContentController = TextEditingController();
        return AlertDialog(
          title: const Text('일기 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: popupTitleController,
                decoration: const InputDecoration(
                  labelText: '제목을 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: popupContentController,
                decoration: const InputDecoration(
                  labelText: '내용을 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _addDiaryEntry(popupTitleController.text, popupContentController.text);
                Navigator.of(context).pop();
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  void _showDiaryContentDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('다이어리'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDate,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDate = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDate = focusedDay;
                _loadDiaryEntries(_focusedDate); // 페이지가 변경될 때마다 데이터 다시 불러오기
              });
            },
            eventLoader: (day) {
              DateTime dayWithoutTime = DateTime(day.year, day.month, day.day);
              return _events[dayWithoutTime] ?? [];
            },
            daysOfWeekHeight: 20 * MediaQuery.of(context).textScaler.textScaleFactor,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: const CalendarStyle(
              cellMargin: EdgeInsets.symmetric(vertical: 8.0),
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(
                fontSize: 18.0, // 기본 날짜 텍스트 크기 설정
              ),
              outsideTextStyle: TextStyle(
                fontSize: 16.0, // 다른 달의 날짜 텍스트 크기 설정
                color: Colors.grey,
              ),
              tableBorder: TableBorder(
                top: BorderSide(color: Colors.black),
                right: BorderSide(color: Colors.black12),
                bottom: BorderSide(color: Colors.black),
                left: BorderSide(color: Colors.black12),
                horizontalInside: BorderSide(color: Colors.black12),
                verticalInside: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.zero,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (day.weekday == DateTime.saturday) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.blue, fontSize: 18.0),
                    ),
                  );
                } else if (day.weekday == DateTime.sunday) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.red, fontSize: 18.0),
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
                    child: _buildEventsMarker(day, events),
                  );
                }
                return null;
              },
            ),
          ),


          Expanded(
            child: userId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('users')
                  .doc(userId)
                  .collection('diaries')
                  .where('date', isGreaterThanOrEqualTo: DateTime(_focusedDate.year, _focusedDate.month, 1))
                  .where('date', isLessThanOrEqualTo: DateTime(_focusedDate.year, _focusedDate.month + 1, 0))
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final documents = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    return ListTile(
                      title: Text(doc['title']),
                      subtitle: Text(doc['date'].toDate().toString()),
                      onTap: () => _showDiaryContentDialog(doc['title'], doc['content']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteDiaryEntry(doc.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
      width: 10.0,
      height: 10.0,
      // child: Center(
      //   child: Text(
      //     '${events.length}',
      //     style: const TextStyle().copyWith(
      //       color: Colors.white,
      //       fontSize: 12.0,
      //     ),
      //   ),
      // ),
    );
  }
}

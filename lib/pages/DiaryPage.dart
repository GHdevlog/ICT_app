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
  String? userId;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(); // 날짜 형식 초기화
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      print("Current user ID: $userId");
    } else {
      print("No user is currently signed in.");
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
      } catch (e) {
        print("Failed to delete diary entry: $e");
      }
    }
  }

  void _showAddEntryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _popupTitleController = TextEditingController();
        final TextEditingController _popupContentController = TextEditingController();
        return AlertDialog(
          title: Text('일기 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _popupTitleController,
                decoration: InputDecoration(
                  labelText: '제목을 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _popupContentController,
                decoration: InputDecoration(
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
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _addDiaryEntry(_popupTitleController.text, _popupContentController.text);
                Navigator.of(context).pop();
              },
              child: Text('추가'),
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
              child: Text('닫기'),
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
        title: Text('Diary'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR', // 한글 설정
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false, // 2weeks 제거
              titleCentered: true,
            ),
          ),
          Expanded(
            child: userId == null
                ? Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
              stream: db.collection('users').doc(userId).collection('diaries').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
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
                        icon: Icon(Icons.delete),
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
        child: Icon(Icons.add),
      ),
    );
  }
}

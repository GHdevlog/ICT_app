import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryEntryPage extends StatefulWidget {
  final DateTime selectedDate;
  final String? userId;
  final FirebaseFirestore db;
  final Function(DateTime) loadDiaryEntries;

  // 생성자
  DiaryEntryPage({
    required this.selectedDate,
    required this.userId,
    required this.db,
    required this.loadDiaryEntries,
  });

  @override
  _DiaryEntryPageState createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  late DateTime _selectedDateTime;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 기본 시각을 설정 (오전 9시)
    _selectedDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      9, // 기본 시간을 오전 9시로 설정
      0,
    );
  }

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDateTime) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  // 시간 선택 함수
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime), // 기본 시각을 표시
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 작성'),
      ),
      // 키보드가 화면을 가리지 않도록 설정
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '제목을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            // 날짜와 시간 선택을 구분하고 아이콘을 왼쪽에 배치
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey), // 박스 테두리 설정
                borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게 설정
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // 박스 내부 여백 설정
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today), // 아이콘을 왼쪽에 배치
                      const SizedBox(width: 8.0),
                      Text(
                        "날짜: ${_selectedDateTime.year}-${_selectedDateTime.month}-${_selectedDateTime.day}",
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: const Text("날짜 선택"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0), // 날짜와 시간 사이의 여백
                  Row(
                    children: [
                      const Icon(Icons.access_time), // 아이콘을 왼쪽에 배치
                      const SizedBox(width: 8.0),
                      Text(
                        "시간: ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}",
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _selectTime(context),
                        child: const Text("시간 선택"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // 내용 입력 칸을 확장하여 화면을 채움
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: '내용을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: null, // 내용 입력이 여러 줄일 때 동적으로 확장
                expands: true, // TextField가 남은 공간을 모두 차지하도록 설정
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    contentController.text.isNotEmpty &&
                    widget.userId != null) {
                  // Firestore에 새로운 일기 데이터 추가
                  await widget.db.collection('users').doc(widget.userId).collection('diaries').add({
                    'title': titleController.text,
                    'content': contentController.text,
                    'date': _selectedDateTime,
                    'createdAt': Timestamp.now(),
                  });
                  // 일기 데이터를 다시 로드
                  widget.loadDiaryEntries(_selectedDateTime);
                  // 작성 후 다이어리 목록 페이지로 돌아감
                  Navigator.of(context).pop();
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}

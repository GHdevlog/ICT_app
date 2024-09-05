import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 일기를 추가하는 다이얼로그를 표시하는 함수
void showAddEntryDialog(
    BuildContext context, // 현재 화면의 context
    DateTime selectedDate, // 사용자가 선택한 날짜
    String? userId, // 현재 사용자의 ID
    FirebaseFirestore db, // Firestore 데이터베이스 인스턴스
    Function(DateTime) loadDiaryEntries // 일기 데이터를 다시 로드하는 함수
    ) {
  // 제목과 내용을 입력받을 텍스트 컨트롤러
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  // 다이얼로그를 화면에 띄움
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('일기 추가'), // 다이얼로그 제목
        content: Column(
          mainAxisSize: MainAxisSize.min, // 내용 크기에 맞춰 다이얼로그 크기 조정
          children: [
            // 제목 입력 필드
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '제목을 입력하세요', // 입력 필드에 표시할 힌트 텍스트
                border: OutlineInputBorder(), // 입력 필드 테두리 스타일
              ),
            ),
            const SizedBox(height: 8.0), // 제목과 내용 입력 필드 사이의 여백
            // 내용 입력 필드
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: '내용을 입력하세요', // 입력 필드에 표시할 힌트 텍스트
                border: OutlineInputBorder(), // 입력 필드 테두리 스타일
              ),
            ),
          ],
        ),
        actions: [
          // 취소 버튼
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
            child: const Text('취소'),
          ),
          // 추가 버튼
          TextButton(
            onPressed: () async {
              // 제목과 내용이 비어있지 않고, 사용자가 존재할 때만 동작
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty &&
                  userId != null) {
                // Firestore에 새로운 일기 데이터 추가
                await db.collection('users').doc(userId).collection('diaries').add({
                  'title': titleController.text, // 입력된 제목
                  'content': contentController.text, // 입력된 내용
                  'date': selectedDate, // 선택된 날짜
                  'createdAt': Timestamp.now(), // 생성 시각
                });
                // 일기 데이터를 다시 로드
                loadDiaryEntries(selectedDate);
                // 다이얼로그 닫기
                Navigator.of(context).pop();
              }
            },
            child: const Text('추가'), // 버튼에 표시할 텍스트
          ),
        ],
      );
    },
  );
}

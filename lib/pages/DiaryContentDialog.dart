import 'package:flutter/material.dart';

// 일기 내용을 보여주는 다이얼로그를 표시하는 함수
void showDiaryContentDialog(BuildContext context, String title, String content) {
  // 다이얼로그를 화면에 띄움
  showDialog(
    context: context, // 현재 화면의 context
    builder: (context) {
      return AlertDialog(
        // 다이얼로그의 제목을 일기의 제목으로 설정
        title: Text(title),
        // 다이얼로그의 내용을 일기의 내용으로 설정
        content: Text(content),
        actions: [
          // 닫기 버튼
          TextButton(
            onPressed: () {
              // 버튼을 누르면 다이얼로그를 닫음
              Navigator.of(context).pop();
            },
            child: const Text('닫기'), // 버튼에 표시할 텍스트
          ),
        ],
      );
    },
  );
}

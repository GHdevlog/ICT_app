import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showAddEntryDialog(BuildContext context, DateTime selectedDate, String? userId, FirebaseFirestore db, Function(DateTime) loadDiaryEntries) {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('일기 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '제목을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: contentController,
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
            onPressed: () async {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty && userId != null) {
                await db.collection('users').doc(userId).collection('diaries').add({
                  'title': titleController.text,
                  'content': contentController.text,
                  'date': selectedDate,
                  'createdAt': Timestamp.now(),
                });
                loadDiaryEntries(selectedDate);
                Navigator.of(context).pop();
              }
            },
            child: const Text('추가'),
          ),
        ],
      );
    },
  );
}

import 'package:flutter/material.dart';

// PredictionResultPage 클래스는 StatelessWidget을 상속받으며 예측 결과를 보여주는 페이지
class PredictionResultPage extends StatelessWidget {
  // 예측 결과를 담을 String? 타입의 변수
  final String? prediction;

  // 생성자, prediction을 초기화
  const PredictionResultPage({super.key, this.prediction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 앱바에 '예측 결과'라는 제목 설정
      appBar: AppBar(
        title: const Text('예측 결과'),
      ),
      body: Center(
        // 중앙에 위젯을 배치
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 위젯들을 중앙에 배치
          children: <Widget>[
            // 예측 결과 텍스트 버전 (현재 주석 처리됨)
            // prediction != null
            //     ? Text('예측 결과: $prediction')
            //     : const Text('예측 결과 없음'),

            // '감사합니다!'라는 텍스트를 보여주는 위젯
            const Text(
              "감사합니다!",
              style: TextStyle(fontSize: 24), // 텍스트 크기를 24로 설정
            ),

            const SizedBox(height: 20), // 텍스트와 버튼 사이에 간격을 줌
            // 돌아가기 버튼, 클릭 시 이전 화면으로 돌아감
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 현재 페이지를 닫고 이전 화면으로 돌아감
              },
              child: const Text('돌아가기'), // 버튼에 표시될 텍스트
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';


class PredictionResultPage extends StatelessWidget {
  final String? prediction;

  const PredictionResultPage({super.key, this.prediction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예측 결과'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 예측 결과 텍스트 ver.
            // prediction != null
            //     ? Text('예측 결과: $prediction')
            //     : const Text('예측 결과 없음'),

            // 감사합니다 ver.
            const Text(
              "감사합니다!",
              style: TextStyle(fontSize: 24), // 폰트 크기를 24로 설정
            ),


            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
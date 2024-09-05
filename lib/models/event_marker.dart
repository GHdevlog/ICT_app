import 'package:flutter/material.dart';

// 이벤트 마커를 생성하는 함수. 날짜와 이벤트 리스트를 받아와 해당 날짜에 표시할 마커를 만듦
Widget buildEventsMarker(DateTime date, List events) {
  return Container(
    // 마커의 모양과 색상을 설정
    decoration: const BoxDecoration(
      shape: BoxShape.circle, // 원형 마커
      color: Colors.red, // 마커의 색상
    ),
    width: 10.0, // 마커의 가로 크기
    height: 10.0, // 마커의 세로 크기
    // 이벤트의 개수를 마커에 표시할 경우 아래의 코드를 사용할 수 있음
    // child: Center(
    //   child: Text(
    //     '${events.length}', // 이벤트 개수를 텍스트로 표시
    //     style: const TextStyle().copyWith(
    //       color: Colors.white, // 텍스트 색상
    //       fontSize: 12.0, // 텍스트 크기
    //     ),
    //   ),
    // ),
  );
}

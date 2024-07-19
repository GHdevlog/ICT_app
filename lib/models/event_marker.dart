import 'package:flutter/material.dart';

Widget buildEventsMarker(DateTime date, List events) {
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

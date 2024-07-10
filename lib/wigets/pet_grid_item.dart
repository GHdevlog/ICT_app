import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ict_face_recog/models/pet.dart';

class PetGridItem extends StatelessWidget {
  final Pet pet;

  const PetGridItem({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            pet.images.isNotEmpty
                ? Image.file(
              File(pet.images.first.path),
              height: 100,
            )
                : Image.asset(
              'assets/dog_silhouette.jpg', // 실루엣 이미지 경로
              height: 100,
            ),
            Text(pet.name),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ict_face_recog/models/pet.dart';

class PetGridItem extends StatelessWidget {
  final Pet pet;
  final bool isDeleteMode;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const PetGridItem({
    super.key,
    required this.pet,
    required this.isDeleteMode,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: pet.images.isNotEmpty
                        ? Image.file(
                      File(pet.images.first.path),
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'assets/dog_silhouette.jpg',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(pet.name, textAlign: TextAlign.center),
                ],
              ),
            ),
            if (isDeleteMode)
              Positioned(
                top: 6,
                right: 6,
                child: InkWell(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

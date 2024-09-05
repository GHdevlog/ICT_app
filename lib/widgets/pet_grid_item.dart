import 'package:flutter/material.dart';
import 'package:ict_face_recog/models/pet.dart';

// PetGridItem 위젯: 반려동물의 정보를 그리드 형태로 보여주는 아이템 위젯
class PetGridItem extends StatelessWidget {
  final Pet pet; // 반려동물 객체
  final bool isDeleteMode; // 삭제 모드 활성화 여부
  final VoidCallback onDelete; // 삭제 버튼 클릭 시 호출되는 함수
  final VoidCallback onTap; // 아이템 클릭 시 호출되는 함수

  // 생성자, 필수적으로 pet, isDeleteMode, onDelete, onTap을 받아옴
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
      onTap: onTap, // 그리드 아이템 클릭 시 호출되는 함수
      child: Container(
        // 아이템의 배경과 외형을 설정
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // 둥근 테두리
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // 그림자 색상
              spreadRadius: 2, // 그림자가 퍼지는 반경
              blurRadius: 5, // 그림자의 흐림 정도
              offset: const Offset(0, 3), // 그림자의 위치
            ),
          ],
        ),
        // 이미지와 이름을 그리드에 표시
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 위젯을 수직 중앙 정렬
                children: [
                  // 이미지 표시
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10), // 이미지의 테두리 둥글게
                    child: pet.images.isNotEmpty
                        ? Image.network(
                      pet.images.first, // 첫 번째 이미지를 표시
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover, // 이미지 비율 유지
                      // 이미지 로드 실패 시 대체 이미지 표시
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/dog_silhouette.jpg', // 대체 이미지 경로
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                        : Image.asset(
                      'assets/dog_silhouette.jpg', // 이미지가 없을 경우 기본 이미지 표시
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8), // 이미지와 텍스트 사이 간격
                  Text(pet.name, textAlign: TextAlign.center), // 반려동물 이름 표시
                ],
              ),
            ),
            // 삭제 모드 활성화 시 삭제 아이콘 표시
            if (isDeleteMode)
              Positioned(
                top: 6, // 삭제 아이콘의 위치 (상단)
                right: 6, // 삭제 아이콘의 위치 (우측)
                child: InkWell(
                  onTap: onDelete, // 삭제 아이콘 클릭 시 onDelete 함수 호출
                  child: const Icon(
                    Icons.delete, // 삭제 아이콘
                    color: Colors.red, // 아이콘 색상
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

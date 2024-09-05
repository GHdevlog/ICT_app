// 반려동물 정보를 저장하는 Pet 클래스
class Pet {
  // 반려동물의 고유 ID
  String id;

  // 반려동물의 이름
  String name;

  // 반려동물의 이미지 URL을 저장하는 리스트
  List<String> images;

  // 반려동물의 비디오 URL을 저장하는 리스트
  List<String> videos;

  // Pet 클래스 생성자
  // 필수적으로 id, name, images, videos를 받아서 초기화
  Pet({
    required this.id,       // 반려동물의 고유 ID
    required this.name,      // 반려동물의 이름
    required this.images,    // 반려동물의 이미지 URL 리스트
    required this.videos,    // 반려동물의 비디오 URL 리스트
  });
}

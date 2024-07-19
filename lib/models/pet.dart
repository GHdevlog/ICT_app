class Pet {
  String id;
  String name;
  List<String> images; // URL 리스트
  List<String> videos; // URL 리스트

  Pet({
    required this.id,
    required this.name,
    required this.images,
    required this.videos,
  });
}

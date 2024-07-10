import 'package:image_picker/image_picker.dart';

class Pet {
  final String name;
  final List<XFile> images;
  final List<XFile> videos;

  Pet({required this.name, required this.images, required this.videos});
}

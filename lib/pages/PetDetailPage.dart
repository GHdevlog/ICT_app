import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:ict_face_recog/models/pet.dart';
import 'package:http/http.dart' as http;

class PetDetailPage extends StatefulWidget {
  final Pet pet;
  final String userId;

  const PetDetailPage({super.key, required this.pet, required this.userId});

  @override
  _PetDetailPageState createState() => _PetDetailPageState();
}
class _PetDetailPageState extends State<PetDetailPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isDeleteMode = false;

  @override
  void initState() {
    super.initState();
    _fetchMedia(); // 페이지 로드 시 이미지 불러오기
  }

  Future<void> _fetchMedia() async {
    final uri = Uri.parse(
        'http://192.168.10.20:5000/get_media?user_id=${widget
            .userId}&pet_id=${widget.pet.id}');

    try {
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        setState(() {
          // API에서 받은 이미지 URL과 비디오 URL을 각각 추가
          widget.pet.images = List<String>.from(jsonResponse['photos']);
          widget.pet.videos = List<String>.from(jsonResponse['videos']);
        });
        // 동영상 URL 확인용 로그
        print("Loaded videos: ${widget.pet.videos}");
      } else {
        Fluttertoast.showToast(msg: '미디어 불러오기 실패');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '서버에 연결할 수 없습니다: $e');
    }
  }


  Future<void> _addImageFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      await _uploadMedia(widget.pet.id, images, true); // pet.id 사용
      setState(() {
        widget.pet.images.addAll(images.map((image) => image.path));
      });
      Fluttertoast.showToast(msg: "이미지 추가 완료");
    } else {
      Fluttertoast.showToast(msg: "이미지 추가 취소");
    }
  }

  Future<void> _addImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      await _uploadMedia(widget.pet.id, [image], true); // pet.id 사용
      setState(() {
        widget.pet.images.add(image.path);
      });
      Fluttertoast.showToast(msg: "이미지 촬영 완료");
    } else {
      Fluttertoast.showToast(msg: "이미지 촬영 취소");
    }
  }

  Future<void> _addVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      await _uploadMedia(widget.pet.id, [video], false); // pet.id 사용
      setState(() {
        widget.pet.videos.add(video.path);
      });
      Fluttertoast.showToast(msg: "비디오 추가 완료");
    } else {
      Fluttertoast.showToast(msg: "비디오 추가 취소");
    }
  }

  Future<void> _uploadMedia(String petId, List<XFile> mediaFiles,
      bool isImage) async {
    final uri = Uri.parse(isImage
        ? 'http://192.168.10.20:5000/upload_images'
        : 'http://192.168.10.20:5000/upload_videos');

    var request = http.MultipartRequest('POST', uri);

    for (var file in mediaFiles) {
      request.files.add(
          await http.MultipartFile.fromPath('files[]', file.path));
    }

    request.fields['user_id'] = widget.userId;
    request.fields['pet_id'] = petId;

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);

        Fluttertoast.showToast(msg: jsonResponse['message']);

        // 업로드가 완료된 후 이미지를 다시 불러오기
        if (isImage) {
          _fetchMedia(); // 이미지일 경우 이미지 목록 갱신
        } else {
          _fetchMedia(); // 비디오일 경우 비디오 목록 갱신하는 함수 추가
        }
      } else {
        Fluttertoast.showToast(msg: '파일 업로드 실패');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '서버에 연결할 수 없습니다: $e');
    }
  }

  void _showPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('카메라로 촬영하기'),
                    onTap: () async {
                      Navigator.pop(context);
                      await _addImageFromCamera();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: const Text('갤러리에서 이미지 선택하기'),
                    onTap: () async {
                      Navigator.pop(context);
                      await _addImageFromGallery();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.video_library),
                    title: const Text('갤러리에서 비디오 선택하기'),
                    onTap: () async {
                      Navigator.pop(context);
                      await _addVideo();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.close),
                    title: const Text('취소'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
    });
  }

  void _deleteImage(int index) {
    setState(() {
      widget.pet.images.removeAt(index);
    });
    Fluttertoast.showToast(msg: "이미지 삭제 완료");
  }

  void _deleteVideo(int index) {
    setState(() {
      widget.pet.videos.removeAt(index);
    });
    Fluttertoast.showToast(msg: "비디오 삭제 완료");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.name),
      ),
      body: Center(
        child: ListView(
          children: [
            // 이미지 표시
            widget.pet.images.isNotEmpty
                ? GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: widget.pet.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  widget.pet.images[index],  // 서버에서 반환된 전체 URL 사용
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/dog_silhouette.jpg',
                      height: 200,
                      fit: BoxFit.cover,
                    );
                  },
                );
              },
            )
                : Image.asset(
              'assets/dog_silhouette.jpg',
              height: 200,
            ),

            const SizedBox(height: 20),

            // 비디오 표시 (비디오가 있을 경우)
            widget.pet.videos.isNotEmpty
                ? GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: widget.pet.videos.length,
              itemBuilder: (context, index) {
                return VideoPlayerWidget(
                  url: widget.pet.videos[index],  // 서버에서 반환된 전체 URL 사용
                );
              },
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}


class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initailizedController;

  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.url);
    _initailizedController = _controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initailizedController,
      builder: (_, snapshot) {
        return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                },
                child: VideoPlayer(_controller)));
      },
    );
  }
}

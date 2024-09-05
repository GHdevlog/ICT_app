import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:ict_face_recog/models/pet.dart';
import 'package:http/http.dart' as http;

// PetDetailPage 위젯, 반려동물의 이미지 및 비디오를 보여주는 페이지
class PetDetailPage extends StatefulWidget {
  final Pet pet; // 반려동물 객체
  final String userId; // 사용자 ID

  const PetDetailPage({super.key, required this.pet, required this.userId});

  @override
  _PetDetailPageState createState() => _PetDetailPageState();
}

// PetDetailPage 상태 관리 클래스
class _PetDetailPageState extends State<PetDetailPage> {
  final ImagePicker _picker = ImagePicker(); // 이미지 및 비디오 선택을 위한 ImagePicker 인스턴스
  bool _isDeleteMode = false; // 삭제 모드 여부를 저장하는 플래그

  @override
  void initState() {
    super.initState();
    _fetchMedia(); // 페이지가 로드될 때 이미지 및 비디오 불러오기
  }

  // 서버에서 반려동물의 이미지 및 비디오 불러오는 함수
  Future<void> _fetchMedia() async {
    final uri = Uri.parse(
        'http://192.168.10.20:5000/get_media?user_id=${widget.userId}&pet_id=${widget.pet.id}');

    try {
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        setState(() {
          // API에서 받은 이미지와 비디오 URL을 각각 추가
          widget.pet.images = List<String>.from(jsonResponse['photos']);
          widget.pet.videos = List<String>.from(jsonResponse['videos']);
        });
        print("Loaded videos: ${widget.pet.videos}"); // 로드된 비디오 로그 출력
      } else {
        Fluttertoast.showToast(msg: '미디어 불러오기 실패');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '서버에 연결할 수 없습니다: $e');
    }
  }

  // 갤러리에서 이미지를 선택하고 서버로 업로드하는 함수
  Future<void> _addImageFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      await _uploadMedia(widget.pet.id, images, true); // pet.id 사용
      setState(() {
        widget.pet.images.addAll(images.map((image) => image.path)); // 이미지 경로 추가
      });
      Fluttertoast.showToast(msg: "이미지 추가 완료");
    } else {
      Fluttertoast.showToast(msg: "이미지 추가 취소");
    }
  }

  // 카메라로 이미지를 촬영하고 서버로 업로드하는 함수
  Future<void> _addImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      await _uploadMedia(widget.pet.id, [image], true); // pet.id 사용
      setState(() {
        widget.pet.images.add(image.path); // 이미지 경로 추가
      });
      Fluttertoast.showToast(msg: "이미지 촬영 완료");
    } else {
      Fluttertoast.showToast(msg: "이미지 촬영 취소");
    }
  }

  // 갤러리에서 비디오를 선택하고 서버로 업로드하는 함수
  Future<void> _addVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      await _uploadMedia(widget.pet.id, [video], false); // pet.id 사용
      setState(() {
        widget.pet.videos.add(video.path); // 비디오 경로 추가
      });
      Fluttertoast.showToast(msg: "비디오 추가 완료");
    } else {
      Fluttertoast.showToast(msg: "비디오 추가 취소");
    }
  }

  // 서버로 이미지 또는 비디오를 업로드하는 함수
  Future<void> _uploadMedia(String petId, List<XFile> mediaFiles, bool isImage) async {
    final uri = Uri.parse(isImage
        ? 'http://192.168.10.20:5000/upload_images'
        : 'http://192.168.10.20:5000/upload_videos');

    var request = http.MultipartRequest('POST', uri);

    // 선택한 파일들을 업로드 요청에 추가
    for (var file in mediaFiles) {
      request.files.add(await http.MultipartFile.fromPath('files[]', file.path));
    }

    request.fields['user_id'] = widget.userId; // 사용자 ID 추가
    request.fields['pet_id'] = petId; // 반려동물 ID 추가

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);

        Fluttertoast.showToast(msg: jsonResponse['message']);

        // 업로드 후 미디어 갱신
        _fetchMedia();
      } else {
        Fluttertoast.showToast(msg: '파일 업로드 실패');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '서버에 연결할 수 없습니다: $e');
    }
  }

  // 이미지 또는 비디오 선택 옵션을 보여주는 바텀 시트
  void _showPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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

  // 삭제 모드를 토글하는 함수
  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode; // 삭제 모드 여부 토글
    });
  }

  // 이미지를 삭제하는 함수
  void _deleteImage(int index) {
    setState(() {
      widget.pet.images.removeAt(index); // 이미지 삭제
    });
    Fluttertoast.showToast(msg: "이미지 삭제 완료");
  }

  // 비디오를 삭제하는 함수
  void _deleteVideo(int index) {
    setState(() {
      widget.pet.videos.removeAt(index); // 비디오 삭제
    });
    Fluttertoast.showToast(msg: "비디오 삭제 완료");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.name), // 앱바 제목
        actions: [
          IconButton(
            icon: Icon(_isDeleteMode ? Icons.delete_forever : Icons.delete),
            onPressed: _toggleDeleteMode, // 삭제 모드 토글 함수 호출
          ),
        ],
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
                return Stack(
                  children: [
                    Image.network(
                      widget.pet.images[index], // 이미지 표시
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/dog_silhouette.jpg', // 오류 시 대체 이미지
                          height: 200,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    if (_isDeleteMode)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteImage(index), // 이미지 삭제
                        ),
                      ),
                  ],
                );
              },
            )
                : Image.asset(
              'assets/dog_silhouette.jpg', // 기본 이미지
              height: 200,
            ),

            const SizedBox(height: 20),

            // 비디오 표시
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
                return Stack(
                  children: [
                    VideoPlayerWidget(
                      url: widget.pet.videos[index], // 비디오 URL 전달
                    ),
                    if (_isDeleteMode)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteVideo(index), // 비디오 삭제
                        ),
                      ),
                  ],
                );
              },
            )
                : Container(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPickerBottomSheet, // 이미지 및 비디오 선택 바텀 시트 표시
        child: const Icon(Icons.add), // 플러스 아이콘
      ),
    );
  }
}

// 비디오 플레이어 위젯
class VideoPlayerWidget extends StatefulWidget {
  final String url; // 비디오 URL

  const VideoPlayerWidget({super.key, required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller; // 비디오 플레이어 컨트롤러
  late Future<void> _initializedController; // 비디오 플레이어 초기화

  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.url); // 비디오 URL 설정
    _initializedController = _controller.initialize(); // 비디오 초기화
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose(); // 비디오 플레이어 종료
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializedController,
      builder: (_, snapshot) {
        return AspectRatio(
          aspectRatio: _controller.value.aspectRatio, // 비디오 비율 설정
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause(); // 비디오 일시정지
                } else {
                  _controller.play(); // 비디오 재생
                }
              });
            },
            child: VideoPlayer(_controller), // 비디오 플레이어 표시
          ),
        );
      },
    );
  }
}

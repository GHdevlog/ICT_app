import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:ict_face_recog/models/pet.dart';

class PetDetailPage extends StatefulWidget {
  final Pet pet;

  const PetDetailPage({Key? key, required this.pet}) : super(key: key);

  @override
  _PetDetailPageState createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isDeleteMode = false;

  Future<void> _addImageFromGallery() async {
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      setState(() {
        widget.pet.images.addAll(images);
      });
      Fluttertoast.showToast(msg: "이미지 추가 완료");
    } else {
      Fluttertoast.showToast(msg: "이미지 추가 취소");
    }
  }

  Future<void> _addImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        widget.pet.images.add(image);
      });
      Fluttertoast.showToast(msg: "이미지 촬영 완료");
    } else {
      Fluttertoast.showToast(msg: "이미지 촬영 취소");
    }
  }

  Future<void> _addVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        widget.pet.videos.add(video);
      });
      Fluttertoast.showToast(msg: "비디오 추가 완료");
    } else {
      Fluttertoast.showToast(msg: "비디오 추가 취소");
    }
  }

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
        actions: [
          IconButton(
            icon: Icon(_isDeleteMode ? Icons.delete_forever : Icons.delete),
            onPressed: _toggleDeleteMode,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView(
                children: [
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
                          GestureDetector(
                            onTap: () {
                              // 이미지를 클릭했을 때의 동작을 여기에 추가할 수 있습니다.
                            },
                            child: Image.file(
                              File(widget.pet.images[index].path),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (_isDeleteMode)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                onTap: () => _deleteImage(index),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  )
                      : Image.asset(
                    'assets/dog_silhouette.jpg', // 실루엣 이미지 경로
                    height: 200,
                  ),
                  const SizedBox(height: 20),
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
                          GestureDetector(
                            onTap: () {
                              // 비디오를 클릭했을 때의 동작을 여기에 추가할 수 있습니다.
                            },
                            child: VideoPlayerWidget(file: File(widget.pet.videos[index].path)),
                          ),
                          if (_isDeleteMode)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                onTap: () => _deleteVideo(index),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showPickerBottomSheet,
              child: const Text('미디어 추가하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final File file;

  const VideoPlayerWidget({Key? key, required this.file}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : Container(
      color: Colors.black,
      height: 100,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

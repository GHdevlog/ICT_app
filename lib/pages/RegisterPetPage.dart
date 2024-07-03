import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPetPage extends StatefulWidget {
  const RegisterPetPage({super.key});

  @override
  State<RegisterPetPage> createState() => _RegisterPetPageState();
}

class _RegisterPetPageState extends State<RegisterPetPage> {
  List<XFile>? _images = [];
  final ImagePicker _picker = ImagePicker();
  String? _uploadResult;

  Future<void> _pickImageFromGallery() async {
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null) {
      setState(() {
        _images = images;
      });
      Fluttertoast.showToast(msg: "이미지 선택 완료");
    } else {
      Fluttertoast.showToast(msg: "이미지 선택 취소");
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _images?.add(image);
      });
      Fluttertoast.showToast(msg: "이미지 촬영 완료");
    } else {
      Fluttertoast.showToast(msg: "이미지 촬영 취소");
    }
  }

  void _showFilePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라로 촬영하기'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('갤러리에서 선택하기'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromGallery();
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
        );
      },
    );
  }

  Future<void> _uploadFile() async {
    if (_images == null || _images!.isEmpty) {
      Fluttertoast.showToast(msg: "파일을 선택하세요");
      return;
    }

    final request = http.MultipartRequest('POST', Uri.parse('http://192.168.10.20:5000/upload_images'));

    for (var image in _images!) {
      request.files.add(await http.MultipartFile.fromPath('files[]', image.path));
    }

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        print("Response JSON: $jsonResponse");

        setState(() {
          _uploadResult = jsonResponse['message'];
        });

        Fluttertoast.showToast(msg: "파일 업로드 완료");
      } else {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        Fluttertoast.showToast(msg: "파일 업로드 실패: ${jsonResponse['error']}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "서버에 연결할 수 없습니다: $e");
    }
  }

  void _viewUploadedImages() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UploadedImagesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('반려동물 등록하기'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _images != null && _images!.isNotEmpty
                ? Wrap(
              children: _images!.map((image) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    File(image.path),
                    height: 100,
                  ),
                );
              }).toList(),
            )
                : Image.asset(
              'assets/dog_silhouette.jpg', // 실루엣 이미지 경로
              height: 200,
            ),
            const SizedBox(height: 20),
            _images != null && _images!.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '선택된 파일: ${_images!.map((image) => image.name).join(', ')}',
                textAlign: TextAlign.center,
              ),
            )
                : const Text('선택된 파일 없음'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showFilePickerBottomSheet,
              child: _images == null || _images!.isEmpty
                  ? const Text('등록할 이미지 선택하기')
                  : const Text('다른 이미지 선택하기'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFile,
              child: const Text('파일 업로드하기'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _viewUploadedImages,
              child: const Text('이전 업로드된 이미지 보기'),
            ),
            const SizedBox(height: 20),
            _uploadResult != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '업로드 결과: $_uploadResult',
                textAlign: TextAlign.center,
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class UploadedImagesPage extends StatefulWidget {
  const UploadedImagesPage({super.key});

  @override
  State<UploadedImagesPage> createState() => _UploadedImagesPageState();
}

class _UploadedImagesPageState extends State<UploadedImagesPage> {
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchUploadedImages();
  }

  Future<void> _fetchUploadedImages() async {
    try {
      final response = await http.get(Uri.parse('http://your-server-url/uploaded_images'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _imageUrls = List<String>.from(jsonResponse['images']);
        });
      } else {
        Fluttertoast.showToast(msg: "이미지 목록을 가져오는 데 실패했습니다.");
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "서버에 연결할 수 없습니다: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이전 업로드된 이미지'),
      ),
      body: _imageUrls.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(_imageUrls[index]),
          );
        },
      ),
    );
  }
}

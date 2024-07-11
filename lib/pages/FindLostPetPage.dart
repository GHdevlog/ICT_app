import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'LoadingPage.dart';
import 'PredictResultPage.dart';

class FindLostPetPage extends StatefulWidget {
  const FindLostPetPage({super.key});

  @override
  State<FindLostPetPage> createState() => _FindLostPetPageState();
}

class _FindLostPetPageState extends State<FindLostPetPage> {
  String? _fileName;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  String? _predictionResult;

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _fileName = image.name;
        _image = image;
      });
      Fluttertoast.showToast(msg: "이미지 선택 완료: $_fileName");
    } else {
      Fluttertoast.showToast(msg: "이미지 선택 취소");
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _fileName = image.name;
        _image = image;
      });
      Fluttertoast.showToast(msg: "이미지 촬영 완료: $_fileName");
    } else {
      Fluttertoast.showToast(msg: "이미지 촬영 취소");
    }
  }

  void _showFilePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
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
    if (_image == null) {
      Fluttertoast.showToast(msg: "파일을 선택하세요");
      return;
    }

    // 로딩 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoadingPage()),
    );

    final request = http.MultipartRequest('POST', Uri.parse('http://192.168.10.20:5000/predict'));
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        print("Response JSON: $jsonResponse");  // 로그 추가

        setState(() {
          _predictionResult = jsonResponse['predictions'].toString(); // 예측 결과를 문자열로 변환
        });

        Fluttertoast.showToast(msg: "파일 업로드 완료");

        // 결과 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PredictionResultPage(prediction: _predictionResult)),
        );
      } else {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        Fluttertoast.showToast(msg: "파일 업로드 실패: ${jsonResponse['error']}");

        // 로딩 페이지 닫기
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "서버에 연결할 수 없습니다: $e");

      // 로딩 페이지 닫기
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실종 동물 찾아주기'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null
                ? Image.file(
              File(_image!.path),
              height: 200,
            )
                : Image.asset(
              'assets/dog_silhouette.jpg', // 실루엣 이미지 경로
              height: 200,
            ),
            const SizedBox(height: 20),
            _fileName != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '선택된 파일: $_fileName',
                textAlign: TextAlign.center,
              ),
            )
                : const Text('선택된 파일 없음'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showFilePickerBottomSheet,
              child: _fileName == null
                  ? const Text('등록할 이미지 선택하기')
                  : const Text('다른 이미지 선택하기'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFile,
              child: const Text('파일 업로드하기'),
            ),
          ],
        ),
      ),
    );
  }
}

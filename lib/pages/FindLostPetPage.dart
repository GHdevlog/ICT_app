import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'LoadingPage.dart'; // 로딩 페이지를 import
import 'PredictResultPage.dart'; // 예측 결과 페이지를 import

// 실종 동물 찾기 페이지 StatefulWidget
class FindLostPetPage extends StatefulWidget {
  const FindLostPetPage({super.key});

  @override
  State<FindLostPetPage> createState() => _FindLostPetPageState();
}

// 상태 관리 클래스
class _FindLostPetPageState extends State<FindLostPetPage> {
  String? _fileName; // 선택한 파일 이름
  XFile? _image; // 선택한 이미지 파일
  final ImagePicker _picker = ImagePicker(); // 이미지 선택을 위한 ImagePicker 인스턴스
  String? _predictionResult; // 예측 결과

  // 갤러리에서 이미지를 선택하는 함수
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _fileName = image.name; // 파일 이름 저장
        _image = image; // 선택된 이미지 저장
      });
      Fluttertoast.showToast(msg: "이미지 선택 완료: $_fileName"); // 성공 메시지
    } else {
      Fluttertoast.showToast(msg: "이미지 선택 취소"); // 취소 시 메시지
    }
  }

  // 카메라로 이미지를 촬영하는 함수
  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _fileName = image.name; // 파일 이름 저장
        _image = image; // 선택된 이미지 저장
      });
      Fluttertoast.showToast(msg: "이미지 촬영 완료: $_fileName"); // 성공 메시지
    } else {
      Fluttertoast.showToast(msg: "이미지 촬영 취소"); // 취소 시 메시지
    }
  }

  // 파일 선택을 위한 바텀 시트를 표시하는 함수
  void _showFilePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
            children: [
              // 카메라로 촬영하기
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라로 촬영하기'),
                onTap: () async {
                  Navigator.pop(context); // 바텀 시트 닫기
                  await _pickImageFromCamera(); // 카메라로 이미지 선택
                },
              ),
              // 갤러리에서 선택하기
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('갤러리에서 선택하기'),
                onTap: () async {
                  Navigator.pop(context); // 바텀 시트 닫기
                  await _pickImageFromGallery(); // 갤러리에서 이미지 선택
                },
              ),
              // 취소
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('취소'),
                onTap: () {
                  Navigator.pop(context); // 바텀 시트 닫기
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 선택된 파일을 서버로 업로드하는 함수
  Future<void> _uploadFile() async {
    if (_image == null) {
      Fluttertoast.showToast(msg: "파일을 선택하세요"); // 파일 미선택 시 경고 메시지
      return;
    }

    // 로딩 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoadingPage()),
    );

    // 파일 업로드 요청 생성
    final request = http.MultipartRequest('POST', Uri.parse('http://192.168.10.20:5000/predict'));
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    try {
      final response = await request.send(); // 서버로 요청 전송

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        print("Response JSON: $jsonResponse"); // 서버 응답 로그 출력

        setState(() {
          _predictionResult = jsonResponse['predictions'].toString(); // 예측 결과 저장
        });

        Fluttertoast.showToast(msg: "파일 업로드 완료"); // 성공 메시지

        // 예측 결과 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PredictionResultPage(prediction: _predictionResult)),
        );
      } else {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        Fluttertoast.showToast(msg: "파일 업로드 실패: ${jsonResponse['error']}"); // 실패 메시지

        // 로딩 페이지 닫기
        Navigator.pop(context);
      }
    } catch (e) {
      print(e); // 에러 로그 출력
      Fluttertoast.showToast(msg: "서버에 연결할 수 없습니다: $e"); // 연결 실패 메시지

      // 로딩 페이지 닫기
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실종 동물 찾아주기'), // 앱바 제목
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
          children: <Widget>[
            // 이미지 표시
            _image != null
                ? Image.file(
              File(_image!.path), // 선택된 이미지 파일 표시
              height: 200,
            )
                : Image.asset(
              'assets/dog_silhouette.jpg', // 기본 이미지 경로
              height: 200,
            ),
            const SizedBox(height: 20), // 간격
            // 선택된 파일 이름 표시
            _fileName != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '선택된 파일: $_fileName',
                textAlign: TextAlign.center, // 중앙 정렬
              ),
            )
                : const Text('선택된 파일 없음'), // 파일이 없을 경우
            const SizedBox(height: 20), // 간격
            // 이미지 선택 버튼
            ElevatedButton(
              onPressed: _showFilePickerBottomSheet, // 파일 선택 바텀 시트 표시
              child: _fileName == null
                  ? const Text('등록할 이미지 선택하기') // 파일 미선택 시 텍스트
                  : const Text('다른 이미지 선택하기'), // 파일 선택 시 텍스트
            ),
            const SizedBox(height: 20), // 간격
            // 파일 업로드 버튼
            ElevatedButton(
              onPressed: _uploadFile, // 파일 업로드 함수 호출
              child: const Text('파일 업로드하기'), // 버튼 텍스트
            ),
          ],
        ),
      ),
    );
  }
}

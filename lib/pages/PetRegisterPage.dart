import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ict_face_recog/models/pet.dart';
import '../widgets/pet_grid_item.dart';
import 'PetDetailPage.dart';

// 반려동물을 등록하는 페이지 위젯 클래스
class RegisterPetPage extends StatefulWidget {
  const RegisterPetPage({super.key});

  @override
  State<RegisterPetPage> createState() => _RegisterPetPageState();
}

// 상태 관리 클래스
class _RegisterPetPageState extends State<RegisterPetPage> {
  final List<Pet> _pets = []; // 반려동물 리스트
  final ImagePicker _picker = ImagePicker(); // 이미지/비디오 선택을 위한 ImagePicker 인스턴스
  bool _isDeleteMode = false; // 삭제 모드 여부를 관리하는 플래그
  String? _userId; // 현재 사용자 ID를 저장

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // 페이지가 로드될 때 현재 사용자 정보 가져오기
  }

  // 현재 로그인된 사용자 정보를 가져오는 함수
  void _getCurrentUser() {
    final User? user = FirebaseAuth.instance.currentUser; // 현재 Firebase 사용자
    if (user != null) {
      setState(() {
        _userId = user.uid; // 사용자 ID 저장
      });
      _loadPets(); // 반려동물 목록 로드
    } else {
      Fluttertoast.showToast(msg: "사용자가 로그인되어 있지 않습니다."); // 로그인된 사용자가 없을 때 메시지 표시
    }
  }

  // Firestore에서 반려동물 목록을 로드하는 함수
  Future<void> _loadPets() async {
    if (_userId != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .get();

      setState(() {
        _pets.clear(); // 기존 목록을 초기화
        for (var doc in snapshot.docs) {
          var data = doc.data();
          _pets.add(Pet(
            id: doc.id, // 반려동물 ID
            name: data['name'], // 반려동물 이름
            images: List<String>.from(data['photos']), // 이미지 URL 리스트
            videos: List<String>.from(data['videos']), // 비디오 URL 리스트
          ));
        }
      });
    }
  }

  // 새로운 반려동물 추가 다이얼로그를 표시하는 함수
  void _showAddPetDialog() {
    String newPetName = ''; // 새로운 반려동물 이름 저장 변수

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('새 반려동물 등록'), // 다이얼로그 제목
          content: TextField(
            onChanged: (value) {
              newPetName = value; // 반려동물 이름 입력 시 변수 업데이트
            },
            decoration: const InputDecoration(hintText: '반려동물 이름'), // 입력 필드 힌트 텍스트
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 취소 버튼 클릭 시 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                if (newPetName.isNotEmpty) {
                  await _addNewPet(newPetName); // 새로운 반려동물 등록 함수 호출
                  Fluttertoast.showToast(msg: "새 반려동물 등록 완료"); // 성공 메시지 표시
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                } else {
                  Fluttertoast.showToast(msg: "이름을 입력하세요"); // 이름 미입력 시 경고 메시지 표시
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // Firestore에 새로운 반려동물을 추가하는 함수
  Future<void> _addNewPet(String name) async {
    if (_userId != null) {
      var newPet = Pet(id: '', name: name, images: [], videos: []); // 새로운 반려동물 객체 생성
      var petDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .add({
        'name': name,
        'photos': [],
        'videos': [],
        'createdAt': Timestamp.now(), // 반려동물 생성 시간
      });
      newPet.id = petDoc.id; // Firestore에서 생성된 문서 ID를 반려동물 ID로 설정
      setState(() {
        _pets.add(newPet); // 반려동물 목록에 추가
      });
    }
  }

  // 이미지 또는 비디오 파일을 서버에 업로드하는 함수
  Future<void> _uploadMedia(String petId, List<XFile> mediaFiles, bool isImage) async {
    // 업로드할 API URL 설정 (이미지 또는 비디오 업로드 여부에 따라 달라짐)
    final uri = Uri.parse(isImage
        ? 'http://192.168.10.20:5000/upload_images'
        : 'http://192.168.10.20:5000/upload_videos');

    var request = http.MultipartRequest('POST', uri);

    // 선택된 파일들을 업로드 요청에 추가
    for (var file in mediaFiles) {
      request.files.add(await http.MultipartFile.fromPath('files[]', file.path));
    }

    request.fields['user_id'] = _userId!; // 사용자 ID를 필드에 추가
    request.fields['pet_id'] = petId; // 반려동물 ID를 필드에 추가

    try {
      var response = await request.send(); // 서버에 요청 전송

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        Fluttertoast.showToast(msg: jsonResponse['message']); // 성공 메시지 표시
      } else {
        Fluttertoast.showToast(msg: '파일 업로드 실패'); // 실패 시 메시지 표시
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '서버에 연결할 수 없습니다: $e'); // 서버 연결 실패 시 메시지 표시
    }
  }

  // 반려동물 상세 페이지로 이동하는 함수
  void _openPetDetailPage(Pet pet) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailPage(pet: pet, userId: _userId!), // 상세 페이지로 이동
      ),
    );
    setState(() {});
  }

  // 삭제 모드 전환 함수
  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode; // 삭제 모드 활성화/비활성화
    });
  }

  // 반려동물 삭제 함수
  void _deletePet(int index) async {
    if (_userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .doc(_pets[index].id)
          .delete(); // Firestore에서 해당 반려동물 삭제
      setState(() {
        _pets.removeAt(index); // UI에서 반려동물 목록에서 삭제
      });
      Fluttertoast.showToast(msg: "반려동물이 삭제되었습니다."); // 삭제 완료 메시지
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('반려동물 등록하기'), // 앱바 제목
        actions: [
          IconButton(
            icon: Icon(_isDeleteMode ? Icons.delete_forever : Icons.delete), // 삭제 모드 여부에 따라 아이콘 변경
            onPressed: _toggleDeleteMode, // 삭제 모드 전환 함수 호출
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 한 행에 두 개의 아이템 표시
                  crossAxisSpacing: 16.0, // 그리드 간격
                  mainAxisSpacing: 16.0, // 그리드 간격
                  childAspectRatio: 3 / 4, // 그리드 아이템의 비율 설정
                ),
                itemCount: _pets.length + 1, // 반려동물 목록 + 추가 버튼을 위해 1개 추가
                itemBuilder: (context, index) {
                  if (index == _pets.length) {
                    return GestureDetector(
                      onTap: _showAddPetDialog, // 추가 버튼 클릭 시 반려동물 등록 다이얼로그 표시
                      child: GridTile(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300], // 추가 버튼 배경 색상
                            borderRadius: BorderRadius.circular(10), // 둥근 테두리
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add, // 추가 아이콘
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return PetGridItem(
                      pet: _pets[index], // 반려동물 정보
                      isDeleteMode: _isDeleteMode, // 삭제 모드 여부
                      onDelete: () => _deletePet(index), // 삭제 함수 호출
                      onTap: () => _openPetDetailPage(_pets[index]), // 상세 페이지로 이동
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

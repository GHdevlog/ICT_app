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

class RegisterPetPage extends StatefulWidget {
  const RegisterPetPage({super.key});

  @override
  State<RegisterPetPage> createState() => _RegisterPetPageState();
}

class _RegisterPetPageState extends State<RegisterPetPage> {
  final List<Pet> _pets = [];
  final ImagePicker _picker = ImagePicker();
  bool _isDeleteMode = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      _loadPets();
    } else {
      Fluttertoast.showToast(msg: "사용자가 로그인되어 있지 않습니다.");
    }
  }

  Future<void> _loadPets() async {
    if (_userId != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .get();

      setState(() {
        _pets.clear();
        for (var doc in snapshot.docs) {
          var data = doc.data();
          _pets.add(Pet(
            id: doc.id, // petID를 추가합니다.
            name: data['name'],
            images: List<String>.from(data['photos']), // URL 리스트로 변환
            videos: List<String>.from(data['videos']), // URL 리스트로 변환
          ));
        }
      });
    }
  }

  void _showAddPetDialog() {
    String newPetName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('새 반려동물 등록'),
          content: TextField(
            onChanged: (value) {
              newPetName = value;
            },
            decoration: const InputDecoration(hintText: '반려동물 이름'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                if (newPetName.isNotEmpty) {
                  await _addNewPet(newPetName);
                  Fluttertoast.showToast(msg: "새 반려동물 등록 완료");
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(msg: "이름을 입력하세요");
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewPet(String name) async {
    if (_userId != null) {
      var newPet = Pet(id: '', name: name, images: [], videos: []);
      var petDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .add({
        'name': name,
        'photos': [],
        'videos': [],
        'createdAt': Timestamp.now(),
      });
      newPet.id = petDoc.id; // 생성된 문서 ID를 newPet의 id로 설정합니다.
      setState(() {
        _pets.add(newPet);
      });
    }
  }

  Future<void> _uploadMedia(String petId, List<XFile> mediaFiles, bool isImage) async {
    // 업로드 api 요청
    final uri = Uri.parse(isImage
        ? 'http://192.168.10.20:5000/upload_images'
        : 'http://192.168.10.20:5000/upload_videos');

    var request = http.MultipartRequest('POST', uri);

    for (var file in mediaFiles) {
      request.files.add(await http.MultipartFile.fromPath('files[]', file.path));
    }

    request.fields['user_id'] = _userId!;
    request.fields['pet_id'] = petId;

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        Fluttertoast.showToast(msg: jsonResponse['message']);
      } else {
        Fluttertoast.showToast(msg: '파일 업로드 실패');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '서버에 연결할 수 없습니다: $e');
    }
  }

  void _openPetDetailPage(Pet pet) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailPage(pet: pet, userId: _userId!),
      ),
    );
    setState(() {});
  }

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
    });
  }

  void _deletePet(int index) async {
    if (_userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .doc(_pets[index].id)
          .delete();
      setState(() {
        _pets.removeAt(index);
      });
      Fluttertoast.showToast(msg: "반려동물이 삭제되었습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('반려동물 등록하기'),
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
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 한 행에 두 개의 아이템을 표시
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 3 / 4, // 비율 설정으로 높이 조정
                ),
                itemCount: _pets.length + 1, // +1 to include the add button
                itemBuilder: (context, index) {
                  if (index == _pets.length) {
                    return GestureDetector(
                      onTap: _showAddPetDialog,
                      child: GridTile(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return PetGridItem(
                      pet: _pets[index],
                      isDeleteMode: _isDeleteMode,
                      onDelete: () => _deletePet(index),
                      onTap: () => _openPetDetailPage(_pets[index]),
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

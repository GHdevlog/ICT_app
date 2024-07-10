import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
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
              onPressed: () {
                if (newPetName.isNotEmpty) {
                  setState(() {
                    _pets.add(Pet(name: newPetName, images: [], videos: []));
                  });
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

  void _openPetDetailPage(Pet pet) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailPage(pet: pet),
      ),
    );
    setState(() {});
  }

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
    });
  }

  void _deletePet(int index) {
    setState(() {
      _pets.removeAt(index);
      Fluttertoast.showToast(msg: "반려동물이 삭제되었습니다.");
    });
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

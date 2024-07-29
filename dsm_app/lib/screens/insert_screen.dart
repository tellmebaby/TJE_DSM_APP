import 'package:dsm_app/api/api.dart';
import 'package:dsm_app/models/starcard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InsertScreen extends StatefulWidget {
  @override
  _InsertScreenState createState() => _InsertScreenState();
}

class _InsertScreenState extends State<InsertScreen> {
  XFile? _image;
  final picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final storage = const FlutterSecureStorage();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      _image = pickedFile;
    });
  }

  Future<int?> _uploadImage() async {
    if (_image == null) return null;

    String? jwtToken = await storage.read(key: 'jwtToken');
    if (jwtToken == null) {
      print('JWT 토큰이 없습니다.');
      return null;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'multipart/form-data',
    };

    try {
      var response = await Api.uploadFile(_image!, headers);
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        return int.parse(response.body); // 성공적으로 업로드된 파일의 번호를 반환
      } else {
        print('Image upload failed');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    int? imgNo = await _uploadImage();
    if (imgNo == null) {
      print('이미지 업로드 실패');
      return;
    }

    String? jwtToken = await storage.read(key: 'jwtToken');
    if (jwtToken == null) {
      print('JWT 토큰이 없습니다.');
      return;
    }

    final starCard = StarCard(
      title: _titleController.text,
      writer: "default_writer",  // 실제 사용자 정보를 사용하도록 변경해야 합니다.
      content: _contentController.text,
      userNo: 1,  // 실제 사용자 정보를 사용하도록 변경해야 합니다.
      payNo: 0,
      card: "default_card",
      category1: "default_category1",
      category2: "default_category2",
      type: "default_type",
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 1)),
      status: "default_status",
      imgNo: imgNo,
    );

    final response = await http.post(
      Uri.parse('http://localhost:8080/starCard'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode(starCard.toJson()),
    );

    if (response.statusCode == 201) {
      print('StarCard created successfully');
      Navigator.pop(context);
    } else {
      print('Failed to create StarCard');
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('카메라로 사진 찍기'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('사진첩에서 선택'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('글 작성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _image == null
                ? Center(child: Text('사진을 찍어주세요'))
                : Image.file(File(_image!.path)),
            SizedBox(height: 16.0),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: '내용'),
              maxLines: 5,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('저장'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceActionSheet(context),
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
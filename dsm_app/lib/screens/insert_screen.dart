import 'package:dsm_app/api/api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class InsertScreen extends StatefulWidget {
  @override
  _InsertScreenState createState() => _InsertScreenState();
}

class _InsertScreenState extends State<InsertScreen> {
  XFile? _image;
  final picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = pickedFile;
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    Map<String, String> headers = {
      'Authorization': 'Bearer your_jwt_token', // JWT 토큰을 여기에 추가하세요.
      'Content-Type': 'multipart/form-data',
    };

    try {
      var response = await Api.uploadFile(_image!, headers);
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        // 성공적으로 업로드된 경우의 처리
      } else {
        print('Image upload failed');
        // 업로드 실패 시의 처리
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
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
              onPressed: () async {
                await _uploadImage();
                // 저장 로직 추가
              },
              child: Text('저장'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
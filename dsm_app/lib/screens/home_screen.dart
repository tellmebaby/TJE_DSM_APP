import 'dart:convert';
import 'package:dsm_app/models/reply.dart';
import 'package:dsm_app/models/starcard.dart';
import 'package:dsm_app/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'insert_screen.dart'; // InsertScreen import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = const FlutterSecureStorage();
  String jwtToken = "";
  List<StarCard> starCards = [];
  final Map<int, TextEditingController> _commentControllers = {};

  @override
  void initState() {
    super.initState();
    loadJwtToken();
    fetchStarCards();
  }

  Future<void> loadJwtToken() async {
    String? token = await storage.read(key: 'jwtToken');

    if (token == null || token == '') {
      print('미리 저장된 jwt 토큰 없음');
      print('로그인 화면으로 이동...');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      jwtToken = token ?? "";
    });
  }

  Future<void> fetchStarCards() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/starCard/List'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes))['starList'];
      setState(() {
        starCards = data.map((item) => StarCard.fromJson(item)).toList();
        _commentControllers.clear();
        for (int i = 0; i < starCards.length; i++) {
          _commentControllers[i] = TextEditingController();
        }
      });
    } else {
      throw Exception('Failed to load star cards');
    }
  }

  Future<void> saveJwtToken(String token) async {
    await storage.write(key: 'jwtToken', value: token);
  }

  Future<void> addComment(int index, String comment) async {
    final card = starCards[index];
    final response = await http.post(
      Uri.parse('http://localhost:8080/reply'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({
        'userNo': card.userNo,
        'starNo': card.starNo,
        'parentNo': 0,  // Assuming it's a root comment
        'writer': card.writer,
        'content': comment,
      }),
    );

    if (response.statusCode == 201) {
      // Add comment and reload comments
      setState(() {
        _commentControllers[index]?.clear();
      });
      // Fetch comments again after adding a comment
      await fetchComments(card.starNo ?? 0);
    } else {
      print('Failed to add comment');
    }
  }

  Future<List<Reply>> fetchComments(int starNo) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/reply/$starNo'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes))['replyList'];
      return data.map((item) => Reply.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Image.asset('assets/images/logo.png', height: 40),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    // 검색 액션 구현
                  },
                ),
                userProvider.isLogin
                    ? PopupMenuButton<String>(
                        icon: CircleAvatar(
                          backgroundImage: NetworkImage('http://localhost:8080/file/img/1'),
                        ),
                        onSelected: (value) {
                          if (value == 'logout') {
                            print('로그아웃 처리...');
                            userProvider.logout();
                          } else if (value == 'mypage') {
                            // 마이 페이지로 이동 구현
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'mypage',
                              child: Text('마이 페이지'),
                            ),
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: Text('로그아웃'),
                            ),
                          ];
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.person, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    // 메뉴 액션 구현
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: starCards.length,
          itemBuilder: (context, index) {
            final card = starCards[index];
            final imgUrl = 'http://localhost:8080/file/img/${card.imgNo}';

            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(0),
              child: Stack(
                children: [
                  Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '제목: ${card.title ?? '제목 없음'}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '작성자: ${card.writer ?? '작성자 없음'}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '내용: ${card.content ?? '내용 없음'}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '등록일: ${card.regDate?.toLocal().toString().split(' ')[0] ?? '등록일 없음'}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),                            SizedBox(height: 8),
                            Text(
                              '수정일: ${card.updDate?.toLocal().toString().split(' ')[0] ?? '수정일 없음'}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '조회수: ${card.views ?? 0}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '좋아요: ${card.likes ?? 0}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '덧글:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            FutureBuilder<List<Reply>>(
                              future: fetchComments(card.starNo ?? 0),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Text('No comments found');
                                } else {
                                  final comments = snapshot.data!;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: comments.map((comment) {
                                      return Text(
                                        '- ${comment.content} (작성자: ${comment.writer})',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }
                              },
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentControllers[index],
                                    decoration: InputDecoration(
                                      labelText: '덧글을 입력하세요',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    addComment(index, _commentControllers[index]?.text ?? '');
                                  },
                                  child: Text('등록'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Container(
          height: 50.0,
          child: Center(
            child: IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white),
              onPressed: () {
                if (userProvider.isLogin) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InsertScreen()),
                  );
                } else {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
                           
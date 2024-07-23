import 'dart:convert';
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
  // FlutterSecureStorage : 안전한 저장소
  final storage = const FlutterSecureStorage();
  String jwtToken = "";
  List<StarCard> starCards = [];

  @override
  void initState() {
    super.initState();
    loadJwtToken();
    fetchStarCards();
  }

  Future<void> loadJwtToken() async {
    // 저장된 JWT 토큰 읽기
    String? token = await storage.read(key: 'jwtToken');

    // 저장된 토큰이 없으면 ➡ 로그인 화면으로
    if (token == null || token == '') {
      print('미리 저장된 jwt 토큰 없음');
      print('로그인 화면으로 이동...');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    // 저장된 토큰이 있으면 ➡ 서버로 사용자 정보 요청

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
      });
    } else {
      throw Exception('Failed to load star cards');
    }
  }

  Future<void> saveJwtToken(String token) async {
    await storage.write(key: 'jwtToken', value: token);
  }

  @override
  Widget build(BuildContext context) {
    // listen: (provider 구독여부)
    // - true : provider 에서 notifyListeners() 호출 시, consumer 리렌더링 ⭕
    // - false : provider 에서 notifyListeners() 호출 시, consumer 리렌더링 ❌
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
                    // Implement search action
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
                            // Implement navigation to My Page
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
                    // Implement menu action
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
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
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
                          ),
                          SizedBox(height: 8),
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
                        ],
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
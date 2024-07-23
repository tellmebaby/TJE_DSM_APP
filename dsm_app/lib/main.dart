import 'package:dsm_app/provider/user_provider.dart';
import 'package:dsm_app/screens/home_screen.dart';
import 'package:dsm_app/screens/login_screen.dart';
import 'package:dsm_app/screens/insert_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // ✅✅✅ 프로바이더 추가
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JWT 토큰 로그인',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/createPost': (context) => InsertScreen(), // InsertScreen 경로 정의
      },
    );
  }
}
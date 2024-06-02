import 'package:flutter/material.dart';
import 'dart:async';
import '../AboutLogin/LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFABCDED),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('WelTrack', style: TextStyle(fontSize: 50)),
            SizedBox(height: 20), // 텍스트와 로딩 바 사이에 공간 추가
            CircularProgressIndicator(), // 로딩 바 추가
          ],
        ),
      ),
    );
  }
}

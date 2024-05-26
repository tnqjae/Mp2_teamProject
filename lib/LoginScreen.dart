import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'WelTrack',
          style: TextStyle(fontSize: 30),
        ),
        backgroundColor: Color(0xFFABCDED),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '아이디',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Add your signup logic here
                  },
                  child: Text('회원가입'),
                ),
                SizedBox(width: 16.0), // 버튼 사이의 공간
                ElevatedButton(
                  onPressed: () {
                    // Add your login logic here
                  },
                  child: Text('로그인'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
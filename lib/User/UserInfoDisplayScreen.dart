import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'UserInfoInputScreen.dart'; // 정보를 수정할 수 있는 화면

class UserInfoDisplayScreen extends StatefulWidget {
  final String username;

  UserInfoDisplayScreen({required this.username});

  @override
  _UserInfoDisplayScreenState createState() => _UserInfoDisplayScreenState();
}

class _UserInfoDisplayScreenState extends State<UserInfoDisplayScreen> {
  Database? _database;
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, 'users.db');

    _database = await openDatabase(
      path,
      version: 2,
    );

    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    final List<Map<String, dynamic>> maps = await _database!.query(
      'userinfo',
      where: 'username = ?',
      whereArgs: [widget.username],
    );

    if (maps.isNotEmpty) {
      setState(() {
        _userInfo = maps.first;
      });
    }
  }

  double _calculateBMRMale(double height, double weight, int age) {
    return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
  }

  double _calculateBMRFemale(double height, double weight, int age) {
    return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
  }

  @override
  Widget build(BuildContext context) {
    if (_userInfo == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('사용자 정보'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final name = widget.username;
    final age = _userInfo!['age'];
    final height = _userInfo!['height'];
    final weight = _userInfo!['weight'];
    final bmrMale = _calculateBMRMale(height, weight, age);
    final bmrFemale = _calculateBMRFemale(height, weight, age);

    return Scaffold(
      appBar: AppBar(
        title: Text('사용자 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이름: $name', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8.0),
            Text('나이: $age', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8.0),
            Text('신장: $height cm', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8.0),
            Text('몸무게: $weight kg', style: TextStyle(fontSize: 20)),
            SizedBox(height: 16.0),
            Text(
              '기초대사량(BMR):',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '남성: ${bmrMale.toStringAsFixed(2)} kcal/day',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '여성: ${bmrFemale.toStringAsFixed(2)} kcal/day',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserInfoScreen(username: widget.username),
                    ),
                  );
                },
                child: Text('내 정보 수정'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }
}

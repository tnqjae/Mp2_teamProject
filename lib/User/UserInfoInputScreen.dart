import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../MainScreen/HomeScreen.dart'; // 홈 화면으로 이동하기 위해 HomeScreen을 임포트합니다.

class UserInfoScreen extends StatefulWidget {
  final String username;

  UserInfoScreen({required this.username});

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  Database? _database;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

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
  }

  Future<void> _saveUserInfo() async {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final age = int.tryParse(_ageController.text);

    if (height == null || weight == null || age == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('입력 오류'),
          content: Text('유효한 값을 입력하세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    await _database!.insert(
      'userinfo',
      {
        'username': widget.username,
        'height': height,
        'weight': weight,
        'age': age,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('저장 완료'),
        content: Text('신체 정보가 저장되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(username: widget.username)),
              );
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('유저 신체 정보 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: '신장 (cm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: '몸무게 (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: '나이',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _saveUserInfo,
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _database?.close();
    super.dispose();
  }
}
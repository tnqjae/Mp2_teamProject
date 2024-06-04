import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:weltrack/User/UserInfoInputScreen.dart';
import 'SignUpScreen.dart';
import '../MainScreen/HomeScreen.dart'; // 로그인 성공 후 이동할 페이지

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Database? _database;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isDatabaseInitialized = false;

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
      version: 2, // 버전을 2로 변경하여 데이터베이스 스키마를 업데이트합니다.
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, username TEXT, password TEXT)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS userinfo(username TEXT PRIMARY KEY, height REAL, weight REAL, age INTEGER)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS userinfo(username TEXT PRIMARY KEY, height REAL, weight REAL, age INTEGER)',
          );
        }
      },
    );

    setState(() {
      _isDatabaseInitialized = true;
    });
  }

  Future<void> _login() async {
    if (!_isDatabaseInitialized) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Database is not initialized yet.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final username = _usernameController.text;
    final password = _passwordController.text;

    final List<Map<String, dynamic>> userMaps = await _database!.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (userMaps.isNotEmpty) {
      final List<Map<String, dynamic>> userInfoMaps = await _database!.query(
        'userinfo',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (userInfoMaps.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(username: username)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserInfoScreen(username: username)),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Failed'),
          content: Text('Invalid username or password.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ActiveLife+',
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
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: Text('Sign Up'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }
}
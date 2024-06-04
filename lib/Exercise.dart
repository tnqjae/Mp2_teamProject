import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Exercise 클래스 정의
class Exercise {
  final String name;
  final int weight;
  final int count;

  Exercise(this.name, this.weight, this.count);
}

class ExerciseCalculator extends StatefulWidget {
  @override
  _KcalCalculatorState createState() => _KcalCalculatorState();
}

class _KcalCalculatorState extends State<ExerciseCalculator> {
  List<Exercise> _exerciseList = [];
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _countController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExerciseList();
  }

  Future<void> _loadExerciseList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final exerciseListData = prefs.getString('exerciseList');
    final savedDate = prefs.getString('savedDate');

    if (exerciseListData != null && savedDate != null) {
      final List<dynamic> parsedExerciseList = json.decode(exerciseListData);
      final DateTime savedDateTime = DateTime.parse(savedDate);
      final DateTime now = DateTime.now();

      // Compare the saved date with the current date
      if (now.difference(savedDateTime).inDays < 1) {
        // If less than 1 day has passed, load the exercise list
        setState(() {
          _exerciseList = parsedExerciseList
              .map((exerciseData) => Exercise(
              exerciseData['name'], exerciseData['weight'], exerciseData['count']))
              .toList();
        });
      } else {
        // If 1 day or more has passed, clear the saved data
        prefs.remove('exerciseList');
        prefs.remove('savedDate');
      }
    }
  }

  Future<void> _saveExerciseList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> exerciseListData = _exerciseList
        .map((exercise) =>
    {'name': exercise.name, 'weight': exercise.weight, 'count': exercise.count})
        .toList();

    // Save the exercise list and current date
    await prefs.setString('exerciseList', json.encode(exerciseListData));
    await prefs.setString('savedDate', DateTime.now().toIso8601String());
  }

  void _addExercise(String name, int weight, int count) {
    setState(() {
      _exerciseList.add(Exercise(name, weight, count));
      _saveExerciseList();
    });
    _exerciseNameController.clear();
    _weightController.clear();
    _countController.clear();
  }

  int _calculateTotalBurnedCalories() {
    return _exerciseList.fold(0, (sum, exercise) => sum + (exercise.weight * exercise.count) ~/ 45);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('운동 칼로리 계산'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _exerciseList.length,
              itemBuilder: (ctx, index) {
                return ListTile(
                  title: Text(_exerciseList[index].name),
                  subtitle: Text('소모 칼로리: ${(_exerciseList[index].weight * _exerciseList[index].count) ~/ 45} kcal'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _exerciseNameController,
                    decoration: InputDecoration(labelText: '운동 이름'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    decoration: InputDecoration(labelText: '무게'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _countController,
                    decoration: InputDecoration(labelText: '횟수'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final exerciseName = _exerciseNameController.text;
                    final weight = int.tryParse(_weightController.text) ?? 0;
                    final count = int.tryParse(_countController.text) ?? 0;
                    if (exerciseName.isNotEmpty && weight > 0 && count > 0) {
                      _addExercise(exerciseName, weight, count);
                    }
                  },
                  child: Text('추가'),
                ),
              ],
            ),
          ),
          Text('오늘 소모한 총 칼로리: ${_calculateTotalBurnedCalories()} kcal',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
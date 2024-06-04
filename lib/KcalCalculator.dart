import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// FoodItem 클래스 정의
class FoodItem {
  final String name;
  final int calories;

  FoodItem(this.name, this.calories);
}

class KcalCalculator extends StatefulWidget {
  @override
  _KcalCalculatorState createState() => _KcalCalculatorState();
}

class _KcalCalculatorState extends State<KcalCalculator> {
  List<FoodItem> _foodList = [];
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFoodList();
  }

  Future<void> _loadFoodList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final foodListData = prefs.getString('foodList');
    final savedDate = prefs.getString('savedDate');

    if (foodListData != null && savedDate != null) {
      final List<dynamic> parsedFoodList = json.decode(foodListData);
      final DateTime savedDateTime = DateTime.parse(savedDate);
      final DateTime now = DateTime.now();

      // Compare the saved date with the current date
      if (now.difference(savedDateTime).inDays < 1) {
        // If less than 1 day has passed, load the food list
        setState(() {
          _foodList = parsedFoodList
              .map((foodData) => FoodItem(foodData['name'], foodData['calories']))
              .toList();
        });
      } else {
        // If 1 day or more has passed, clear the saved data
        prefs.remove('foodList');
        prefs.remove('savedDate');
      }
    }
  }

  Future<void> _saveFoodList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> foodListData =
    _foodList.map((food) => {'name': food.name, 'calories': food.calories}).toList();

    // Save the food list and current date
    await prefs.setString('foodList', json.encode(foodListData));
    await prefs.setString('savedDate', DateTime.now().toIso8601String());
  }

  void _addFood(String name, int calories) {
    setState(() {
      _foodList.add(FoodItem(name, calories));
      _saveFoodList();
    });
    _foodNameController.clear();
    _caloriesController.clear();
  }

  int _calculateTotalCalories() {
    return _foodList.fold(0, (sum, food) => sum + food.calories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('음식 칼로리 추적기'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _foodList.length,
              itemBuilder: (ctx, index) {
                return ListTile(
                  title: Text(_foodList[index].name),
                  subtitle: Text('${_foodList[index].calories} kcal'),
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
                    controller: _foodNameController,
                    decoration: InputDecoration(labelText: '음식 이름'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _caloriesController,
                    decoration: InputDecoration(labelText: '칼로리'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final foodName = _foodNameController.text;
                    final calories = int.tryParse(_caloriesController.text) ?? 0;
                    if (foodName.isNotEmpty && calories > 0) {
                      _addFood(foodName, calories);
                    }
                  },
                  child: Text('추가'),
                ),
              ],
            ),
          ),
          Text('오늘 먹은 총 칼로리: ${_calculateTotalCalories()} kcal',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
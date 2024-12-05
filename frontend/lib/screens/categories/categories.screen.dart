import 'dart:convert';

import 'package:finbot/models/CategoryResponseModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../models/category.model.dart';
import '../../widgets/dialog/category_form.dialog.dart';



class CategoriesScreen extends StatefulWidget {
  final int? userId;

  const CategoriesScreen(this.userId, {super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _isLoading = false;
  List<Category> _categories = [];
  CategoryResponse? categoryResponse;

  static const List<Color> colorSet = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.red,
    Colors.cyan,
    Colors.indigo,
    Colors.pink,
  ];

  static const List<IconData> iconSet = [
    Icons.home,
    Icons.shopping_cart,
    Icons.food_bank,
    Icons.directions_car,
    Icons.healing,
    Icons.travel_explore,
    Icons.fitness_center,
    Icons.pets,
    Icons.lightbulb,
  ];

// Function to get color and icon based on index or ID
  Color getColor(int index) => colorSet[index % colorSet.length];
  IconData getIcon(int index) => iconSet[index % iconSet.length];

  void loadData() async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl = "https://finbot-fastapi-rc4376baha-ue.a.run.app/category/" + widget.userId.toString();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      categoryResponse = CategoryResponse.fromJson(data);
    } else {
      throw Exception('Failed to load categories');
    }

    setState(() {
      _categories = categoryResponse?.categories ?? [];
      _isLoading = false;
    });
  }

  void _openCategoryForm({Category? category}) {
    showDialog(
      context: context,
      builder: (context) => CategoryForm(
        category: category,
        userId: widget.userId,
        onSave: () {
          loadData();
        },
        onDelete: () {
          loadData();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Categories",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView.separated(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          Category category = _categories[index];
          double expenseProgress = (category.expense ?? 0) / (category.budget ?? 0);
          return ListTile(
            onTap: () => _openCategoryForm(category: category),
            leading: CircleAvatar(
              backgroundColor: getColor(index).withOpacity(0.2),
              child: Icon(
                getIcon(index),
                color: getColor(index),
              ),
            ),
            title: Text(
              category.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            subtitle: expenseProgress.isFinite
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: expenseProgress,
                semanticsLabel: expenseProgress.toString(),
              ),
            )
                : Text(
              "No budget",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.apply(color: Colors.grey, overflow: TextOverflow.ellipsis),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            width: double.infinity,
            color: Colors.grey.withAlpha(25),
            height: 1,
            margin: const EdgeInsets.only(left: 75, right: 20),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCategoryForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}


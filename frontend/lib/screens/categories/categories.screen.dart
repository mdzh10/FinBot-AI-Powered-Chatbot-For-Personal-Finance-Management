import 'dart:convert';

import 'package:events_emitter/events_emitter.dart';
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
  // final CategoryDao _categoryDao = CategoryDao();
  EventListener? _categoryEventListener;
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

    final String apiUrl = "http://192.168.160.192:8000/category/";
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

    List<Category> categories = categoryResponse?.categories ?? [];
    setState(() {
      _categories = categories;
    });

  }


  @override
  void initState() {
    super.initState();
    loadData();
    // _categoryEventListener = globalEvent.on("category_update", (data){
    //   debugPrint("categories are changed");
    //   loadData();
    // });
  }

  @override
  void dispose() {

    _categoryEventListener?.cancel();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Categories", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
        ),
        body: ListView.separated(
          itemCount: _categories.length,
          itemBuilder: (builder, index){
            Category category = _categories[index];
            double expenseProgress = (category.expense??0)/(category.budget??0);
            return ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (builder) => CategoryForm(category: category),
                );
              },
              leading: CircleAvatar(
                backgroundColor: getColor(index).withOpacity(0.2), // Set background color
                child: Icon(
                  getIcon(index), // Set icon
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
          separatorBuilder: (BuildContext context, int index){
            return Container(
              width: double.infinity,
              color: Colors.grey.withAlpha(25),
              height: 1,
              margin: const EdgeInsets.only(left: 75, right: 20),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            showDialog(context: context, builder: (builder)=>const CategoryForm());
          },
          child: const Icon(Icons.add),
        )
    );
  }
}

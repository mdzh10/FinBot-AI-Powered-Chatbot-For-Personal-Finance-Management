import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../data/icons.dart';
import '../../models/category.model.dart';
import '../buttons/button.dart';
import '../currency.dart';
typedef Callback = void Function();
class CategoryForm extends StatefulWidget {
  final Category? category;
  final Callback? onSave;

  const CategoryForm({super.key, this.category, this.onSave});

  @override
  State<StatefulWidget> createState() => _CategoryForm();
}
class _CategoryForm extends State<CategoryForm>{
  // final CategoryDao _categoryDao = CategoryDao();
  final TextEditingController _nameController = TextEditingController();
  Category _category = Category(name: "");
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if(widget.category != null){
      _nameController.text = widget.category!.name;
      _category = widget.category??Category(name: "");
    }
  }

  void onSave (context) async{

    if (widget.category != null) {
      _category = Category(
        id: widget.category!.id,
        // userId: widget.userId,
        name: widget.category!.name,
        budget: widget.category!.budget,
        expense: widget.category!.expense,
      );
    } else {
      _category = Category(
        // userId: widget.userId,
        name: "",
        budget: 0
      );
    }


    setState(() {
      _isSaving = true; // Show loading indicator
    });

    try {
      final url = _category?.id == null
          ? Uri.parse('http://192.168.160.192:8000/category/create')
          : Uri.parse('http://192.168.160.192:8000/category/update');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(_category?.toJson()),
      );

      if (response.statusCode == 200) {
        print("Category saved successfully: ${jsonDecode(response.body)}");
      } else {
        print("Failed to save category: ${response.body}");
        throw Exception("Failed to save category");
      }

      if (widget.onSave != null) {
        widget.onSave!();
      }
      Navigator.pop(context);
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isSaving = false; // Hide loading indicator
      });
    }

    // await _categoryDao.upsert(_category);
    if(widget.onSave != null) {
      widget.onSave!();
    }
    Navigator.pop(context);
    // globalEvent.emit("category_update");
  }

  void pickIcon(context)async {

  }
  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(10),
      title: Text(widget.category!=null?"Edit Category":"New Category", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(40)
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.wallet, color: Colors.white,),
                ),
                const SizedBox(width: 15,),
                Expanded(
                    child: TextFormField(
                      initialValue: _category.name,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter Category name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15)
                      ),
                      onChanged: (String text){
                        setState(() {
                          _category.name = text;
                        });
                      },
                    )
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                initialValue: _category.budget == null ?"":_category.budget.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                ],
                decoration: InputDecoration(
                    labelText: 'Budget',
                    hintText: 'Enter budget',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  prefixIcon: Padding(padding: const EdgeInsets.only(left: 15), child: CurrencyText(null)),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                onChanged: (String text){
                  setState(() {
                    _category.budget = double.parse(text.isEmpty? "0":text);
                  });
                },
              ),
            ),
            const SizedBox(height: 20,),
            //Color picker
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: Colors.primaries.length,
                  itemBuilder: (BuildContext context, index)=>
                      Container(
                        width: 45,
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                // _category.color = Colors.primaries[index];
                              });
                            },
                            child:  Container(
                              decoration: BoxDecoration(
                                  color: Colors.primaries[index],
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.white,
                                  )
                              ),
                            )
                        ),
                      )

              ),
            ),
            const SizedBox(height: 15,),

            //Icon picker
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppIcons.icons.length,
                  itemBuilder: (BuildContext context, index)=>Container(
                      width: 45,
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              // _category.icon = AppIcons.icons[index];
                            });
                          },
                          child:  Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2
                                )
                            ),
                            child:Icon(AppIcons.icons[index], color: Theme.of(context).colorScheme.primary, size: 18,),
                          )
                      )
                  )

              ),
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          height: 45,
          isFullWidth: true,
          onPressed: (){
            onSave(context);
          },
          color: Theme.of(context).colorScheme.primary,
          label: "Save",
        )
      ],
    );

  }

}
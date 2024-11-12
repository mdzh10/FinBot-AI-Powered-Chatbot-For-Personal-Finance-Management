import 'category.model.dart';

class CategoryResponse {
  bool isSuccess;
  String msg;
  List<Category> categories;

  CategoryResponse({
    required this.isSuccess,
    required this.msg,
    required this.categories,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      isSuccess: json["isSuccess"],
      msg: json["msg"],
      categories: List<Category>.from(json["data"].map((item) => Category.fromJson(item))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "isSuccess": isSuccess,
      "msg": msg,
      "data": categories.map((category) => category.toJson()).toList(),
    };
  }
}

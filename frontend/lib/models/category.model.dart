class Category {
  int? id;
  int? userId;
  String name;
  double? budget;
  double? expense;

  Category({
    this.id,
    this.userId,
    required this.name,
    this.budget,
    this.expense
  });

  factory Category.fromJson(Map<String, dynamic> data) => Category(
    id: data["id"],
    userId: data["user_id"],
    name: data["name"],
    budget: data["budget"] ?? 0,
    expense: data["expense"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id":userId,
    "name": name,
    "budget": budget,
    "expense":expense
  };
}
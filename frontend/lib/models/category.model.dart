class Category {
  int? id;
  String name;
  double? budget;
  double? expense;

  Category({
    this.id,
    required this.name,
    this.budget,
    this.expense
  });

  factory Category.fromJson(Map<String, dynamic> data) => Category(
    id: data["id"],
    name: data["name"],
    budget: data["budget"] ?? 0,
    expense: data["expense"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "budget": budget,
  };
}
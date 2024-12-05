class TransactionForImage {
   int? userId;
   int? accountId;
   int? categoryId;
   String? title;
   String? description;
   double? amount;
   String? type;
   DateTime? datetime;

  TransactionForImage({
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.datetime,
  });

  factory TransactionForImage.fromJson(Map<String, dynamic> json) {
    return TransactionForImage(
      userId: json['user_id'],
      accountId: json['account_id'],
      categoryId: json['category_id'],
      title: json['title'],
      description: json['description'],
      amount: json['amount'],
      type: json['type'],
      datetime: DateTime.parse(json['datetime']),
    );
  }
}
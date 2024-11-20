class TransactionRequest {
  final int userId;
  final int accountId;
  final int categoryId;
  final String title;
  final String description;
  final double amount;
  final String type;
  final DateTime datetime;

  TransactionRequest({
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.datetime,
  });

 
  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "account_id": accountId,
      "category_id": categoryId,
      "title": title,
      "description": description,
      "amount": amount,
      "type": type,
      "datetime": datetime.toIso8601String(),
    };
  }
}

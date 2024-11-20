import 'Account.dart';
import 'category.model.dart';

enum TransactionType { debit, credit }

extension TransactionTypeExtension on TransactionType {
  static TransactionType fromString(String type) {
    switch (type) {
      case 'debit':
        return TransactionType.debit;
      case 'credit':
        return TransactionType.credit;
      default:
        throw ArgumentError('Unknown TransactionType: $type');
    }
  }

  String toJson() {
    switch (this) {
      case TransactionType.debit:
        return 'debit';
      case TransactionType.credit:
        return 'credit';
    }
  }

  String get displayName {
    switch (this) {
      case TransactionType.debit:
        return 'Debit';
      case TransactionType.credit:
        return 'Credit';
    }
  }
}


class Transaction {
  final int id;
  final Account account; // Assuming you already have an Account class
  final int userId;
  final Category category; // Assuming you already have a Category class
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime datetime;

  Transaction({
    required this.id,
    required this.account,
    required this.userId,
    required this.category,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.datetime,
  });

  // Factory constructor to create a Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      account: Account.fromJson(json['account']), // Assuming your Account class has fromJson
      userId: json['user_id'],
      category: Category.fromJson(json['category']), // Assuming your Category class has fromJson
      title: json['title'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      type: TransactionTypeExtension.fromString(json["type"]),
      datetime: DateTime.parse(json['datetime']),
    );
  }
}

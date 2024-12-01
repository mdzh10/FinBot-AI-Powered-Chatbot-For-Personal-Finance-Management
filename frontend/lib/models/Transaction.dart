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
  final int? id;
  final Account? account;
  final int? userId;
  final Category? category;
  final String? title;
  final String? description;
  bool? isExceed;
  final double? amount;
  final TransactionType? type;
  final DateTime? datetime;

  Transaction({
    required this.id,
    required this.account,
    required this.userId,
    required this.category,
    required this.title,
    required this.description,
    this.isExceed,
    required this.amount,
    required this.type,
    required this.datetime,
  });

  // Factory constructor to create a Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      account: json['account'] != null ? Account.fromJson(json['account']) : null,
      userId: json['user_id'],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      title: json['title'],
      description: json['description'],
      isExceed: json['isExceed'],
      amount: (json['amount'] as num?)?.toDouble(),
      type: json['type'] != null ? TransactionTypeExtension.fromString(json['type']) : null,
      datetime: json['datetime'] != null ? DateTime.parse(json['datetime']) : DateTime.now(),
    );
  }


  // Convert a Transaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account?.toJson(),
      'user_id': userId,
      'category': category?.toJson(),
      'title': title,
      'description': description,
      'amount': amount,
      'type': type?.toJson(),
      'datetime': datetime?.toIso8601String(),
      // 'isExceed' is excluded here
    };
  }

}


import 'Transaction.dart';

class TransactionResponse {
  final bool isSuccess;
  final String msg;
  final List<Transaction> transactions;

  TransactionResponse({
    required this.isSuccess,
    required this.msg,
    required this.transactions,
  });

  // Factory constructor to create a TransactionResponse from JSON
  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    var transactionsList = json['transactions'] as List;
    List<Transaction> transactions = transactionsList.map((i) => Transaction.fromJson(i)).toList();

    return TransactionResponse(
      isSuccess: json['isSuccess'],
      msg: json['msg'],
      transactions: transactions,
    );
  }
}

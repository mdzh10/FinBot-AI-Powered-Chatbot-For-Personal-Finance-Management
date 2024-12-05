import 'TransactionForImage.dart';

class ReceiptResponse {
  final bool isSuccess;
  final String msg;
  final List<TransactionForImage> transactions;

  ReceiptResponse({
    required this.isSuccess,
    required this.msg,
    required this.transactions,
  });

  factory ReceiptResponse.fromJson(Map<String, dynamic> json) {
    return ReceiptResponse(
      isSuccess: json['isSuccess'],
      msg: json['msg'],
      transactions: (json['transactions'] as List<dynamic>).map((transactionData) => TransactionForImage.fromJson(transactionData)).toList(),
    );
  }
}

import 'Account.dart';

class AccountResponseModel {
  bool isSuccess;
  String msg;
  List<Account> accounts;

  AccountResponseModel({
    required this.isSuccess,
    required this.msg,
    required this.accounts,
  });

  factory AccountResponseModel.fromJson(Map<String, dynamic> data) {
    return AccountResponseModel(
      isSuccess: data["isSuccess"] ?? false,
      msg: data["msg"] ?? "",
      accounts: (data["account"] is List)
          ? (data["account"] as List)
          .map((json) => Account.fromJson(json))
          .toList()
          : [], // Return an empty list if "account" is null or not a list
    );
  }
}
